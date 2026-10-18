using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ZendaAPI.Connection;
using ZendaAPI.Interfaces;
using ZendaAPI.Requests.Profile;

namespace ZendaAPI.Services
{
    public class ProfileService : IProfileService
    {
        private readonly ContextDb _context;
        private readonly IWebHostEnvironment _environment;
        private const int ProjectStatusActive = 1;
        private const int TaskStatusDone = 2;
        private const long MaxAvatarSize = 5 * 1024 * 1024;
        private static readonly string[] AllowedExtensions = { ".jpg", ".jpeg", ".png", ".webp" };

        public ProfileService(ContextDb context, IWebHostEnvironment environment)
        {
            _context = context;
            _environment = environment;
        }

        private string AvatarsFolder => Path.Combine(_environment.ContentRootPath, "wwwroot", "avatars");

        public async Task<IActionResult> Get(int userId)
        {
            var user = await _context.Users
                .Include(u => u.Language)
                .FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null)
                return new NotFoundObjectResult(new { status = false, message = "Пользователь не найден", data = (object)null });

            var weekAgo = DateTime.UtcNow.AddDays(-7);
            var completedThisWeek = await _context.TaskItems.CountAsync(t =>
                t.Project.UserId == userId
                && t.StatusId == TaskStatusDone
                && t.CompletedAt != null
                && t.CompletedAt >= weekAgo);

            var activeProjects = await _context.Projects.CountAsync(p =>
                p.UserId == userId && p.StatusId == ProjectStatusActive);

            var since = DateTime.UtcNow.AddDays(-120);
            var completionDates = await _context.TaskItems
                .Where(t => t.Project.UserId == userId && t.CompletedAt != null && t.CompletedAt >= since)
                .Select(t => t.CompletedAt!.Value)
                .ToListAsync();

            var days = completionDates.Select(d => d.ToLocalTime().Date).ToHashSet();
            var cursor = DateTime.Now.Date;
            if (!days.Contains(cursor)) cursor = cursor.AddDays(-1);
            var streak = 0;
            while (days.Contains(cursor))
            {
                streak++;
                cursor = cursor.AddDays(-1);
            }

            return new OkObjectResult(new
            {
                status = true,
                message = "Успешно",
                data = new
                {
                    user.Id,
                    user.FirstName,
                    user.LastName,
                    user.Email,
                    user.Workplace,
                    user.AvatarUrl,
                    user.LanguageId,
                    LanguageCode = user.Language?.Code,
                    LanguageName = user.Language?.Name,
                    Stats = new
                    {
                        completedThisWeek,
                        streakDays = streak,
                        activeProjects
                    }
                }
            });
        }

        public async Task<IActionResult> Update(int userId, UpdateProfileModel model)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null)
                return new NotFoundObjectResult(new { status = false, message = "Пользователь не найден", data = (object)null });

            user.FirstName = model.FirstName.Trim();
            user.LastName = model.LastName.Trim();
            user.Workplace = string.IsNullOrWhiteSpace(model.Workplace) ? null : model.Workplace.Trim();
            await _context.SaveChangesAsync();

            return new OkObjectResult(new { status = true, message = "Профиль обновлён", data = (object)null });
        }

        public async Task<IActionResult> UpdateLanguage(int userId, UpdateLanguageModel model)
        {
            var exists = await _context.Languages.AnyAsync(l => l.Id == model.LanguageId);
            if (!exists)
                return new BadRequestObjectResult(new { status = false, message = "Неизвестный язык", data = (object)null });

            var user = await _context.Users.FindAsync(userId);
            if (user == null)
                return new NotFoundObjectResult(new { status = false, message = "Пользователь не найден", data = (object)null });

            user.LanguageId = model.LanguageId;
            await _context.SaveChangesAsync();

            return new OkObjectResult(new { status = true, message = "Язык сохранён", data = (object)null });
        }

        public async Task<IActionResult> UploadAvatar(int userId, IFormFile? file)
        {
            if (file == null || file.Length == 0)
                return new BadRequestObjectResult(new { status = false, message = "Файл не выбран", data = (object)null });

            if (file.Length > MaxAvatarSize)
                return new BadRequestObjectResult(new { status = false, message = "Фото должно быть не больше 5 МБ", data = (object)null });

            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            if (!AllowedExtensions.Contains(extension))
                return new BadRequestObjectResult(new { status = false, message = "Подходят только JPG, PNG и WEBP", data = (object)null });

            var user = await _context.Users.FindAsync(userId);
            if (user == null)
                return new NotFoundObjectResult(new { status = false, message = "Пользователь не найден", data = (object)null });

            Directory.CreateDirectory(AvatarsFolder);
            var fileName = $"{userId}_{Guid.NewGuid():N}{extension}";
            await using (var stream = File.Create(Path.Combine(AvatarsFolder, fileName)))
            {
                await file.CopyToAsync(stream);
            }

            if (!string.IsNullOrEmpty(user.AvatarUrl))
            {
                var oldPath = Path.Combine(AvatarsFolder, Path.GetFileName(user.AvatarUrl));
                if (File.Exists(oldPath)) File.Delete(oldPath);
            }

            user.AvatarUrl = $"/avatars/{fileName}";
            await _context.SaveChangesAsync();

            return new OkObjectResult(new { status = true, message = "Фото обновлено", data = new { avatarUrl = user.AvatarUrl } });
        }
    }
}