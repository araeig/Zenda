using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ZendaAPI.Connection;
using ZendaAPI.Interfaces;
using ZendaAPI.Requests.Attachments;
using ZendaAPI.UniversalMethods;
using AttachmentModel = ZendaAPI.Models.Attachment;

namespace ZendaAPI.Services
{
    public class AttachmentService : IAttachmentService
    {
        private readonly ContextDb _context;
        private readonly IWebHostEnvironment _environment;
        private readonly RagClient _ragClient;
        private const long MaxFileSize = 20 * 1024 * 1024;
        private static readonly string[] IndexableExtensions =
            { ".pdf", ".docx", ".txt", ".md", ".csv", ".jpg", ".jpeg", ".png", ".webp" };
        public AttachmentService(ContextDb context, IWebHostEnvironment environment, RagClient ragClient)
        {
            _context = context;
            _environment = environment;
            _ragClient = ragClient;
        }

        private async Task<bool> OwnsTarget(int userId, int? taskItemId, int? eventId)
        {
            if (taskItemId.HasValue == eventId.HasValue) return false;

            if (taskItemId.HasValue)
                return await _context.TaskItems.AnyAsync(t => t.Id == taskItemId && t.Project.UserId == userId);

            return await _context.Events.AnyAsync(e => e.Id == eventId && e.UserId == userId);
        }

        private async Task<string> OwnerText(int? taskItemId, int? eventId)
        {
            if (taskItemId.HasValue)
            {
                var title = await _context.TaskItems.Where(t => t.Id == taskItemId).Select(t => t.Title).FirstOrDefaultAsync();
                return $"к задаче «{title}»";
            }

            var eventTitle = await _context.Events.Where(e => e.Id == eventId).Select(e => e.Title).FirstOrDefaultAsync();
            return $"к событию «{eventTitle}»";
        }

        private static object ToDto(AttachmentModel a) => new { a.Id, a.Label, a.Url, a.TypeId, a.TaskItemId, a.EventId };

        public async Task<IActionResult> Upload(int userId, IFormFile? file, int? taskItemId, int? eventId, string? label)
        {
            if (!await OwnsTarget(userId, taskItemId, eventId))
                return new BadRequestObjectResult(new { status = false, message = "Задача или событие не найдены", data = (object)null });

            if (file == null || file.Length == 0)
                return new BadRequestObjectResult(new { status = false, message = "Файл не выбран", data = (object)null });

            if (file.Length > MaxFileSize)
                return new BadRequestObjectResult(new { status = false, message = "Файл должен быть не больше 20 МБ", data = (object)null });

            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            if (AttachmentStorage.IsBlocked(extension))
                return new BadRequestObjectResult(new { status = false, message = "Такой тип файла загружать нельзя", data = (object)null });

            var folder = AttachmentStorage.Folder(_environment.ContentRootPath);
            Directory.CreateDirectory(folder);
            var fileName = $"{userId}_{Guid.NewGuid():N}{extension}";
            var filePath = Path.Combine(folder, fileName);
            await using (var stream = File.Create(filePath))
            {
                await file.CopyToAsync(stream);
            }

            var cleanLabel = string.IsNullOrWhiteSpace(label) ? Path.GetFileName(file.FileName) : label.Trim();
            if (cleanLabel.Length > 100) cleanLabel = cleanLabel[..100];

            var attachment = new AttachmentModel
            {
                TaskItemId = taskItemId,
                EventId = eventId,
                TypeId = AttachmentStorage.TypeForExtension(extension),
                Label = cleanLabel,
                Url = AttachmentStorage.UrlPrefix + fileName
            };

            _context.Attachments.Add(attachment);
            await _context.SaveChangesAsync();

            if (IndexableExtensions.Contains(extension))
            {
                var owner = await OwnerText(taskItemId, eventId);
                _ = _ragClient.IndexFileAsync(userId, attachment.Id, cleanLabel, owner, filePath);
            }

            return new OkObjectResult(new { status = true, message = "Вложение добавлено", data = ToDto(attachment) });
        }

        public async Task<IActionResult> AddLink(int userId, AddLinkModel model)
        {
            if (!await OwnsTarget(userId, model.TaskItemId, model.EventId))
                return new BadRequestObjectResult(new { status = false, message = "Задача или событие не найдены", data = (object)null });

            var raw = model.Url.Trim();
            if (!raw.StartsWith("http://", StringComparison.OrdinalIgnoreCase)
                && !raw.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
                raw = "https://" + raw;

            if (!Uri.TryCreate(raw, UriKind.Absolute, out var uri) || !uri.Host.Contains('.'))
                return new BadRequestObjectResult(new { status = false, message = "Похоже, это не ссылка", data = (object)null });

            var attachment = new AttachmentModel
            {
                TaskItemId = model.TaskItemId,
                EventId = model.EventId,
                TypeId = AttachmentStorage.TypeForLink(uri),
                Label = string.IsNullOrWhiteSpace(model.Label) ? uri.Host.Replace("www.", "") : model.Label.Trim(),
                Url = uri.ToString()
            };

            _context.Attachments.Add(attachment);
            await _context.SaveChangesAsync();

            return new OkObjectResult(new { status = true, message = "Ссылка добавлена", data = ToDto(attachment) });
        }

        public async Task<IActionResult> Delete(int userId, int attachmentId)
        {
            var attachment = await _context.Attachments
                .Include(a => a.TaskItem).ThenInclude(t => t!.Project)
                .Include(a => a.Event)
                .FirstOrDefaultAsync(a => a.Id == attachmentId);

            var owns = attachment != null
                && ((attachment.TaskItem != null && attachment.TaskItem.Project.UserId == userId)
                    || (attachment.Event != null && attachment.Event.UserId == userId));

            if (!owns)
                return new NotFoundObjectResult(new { status = false, message = "Вложение не найдено", data = (object)null });

            _context.Attachments.Remove(attachment!);
            await _context.SaveChangesAsync();
            AttachmentStorage.DeleteFile(_environment.ContentRootPath, attachment!.Url);
            await _ragClient.DeleteIndexAsync(userId, "attachment", attachmentId);

            return new OkObjectResult(new { status = true, message = "Удалено", data = (object)null });
        }
    }
}