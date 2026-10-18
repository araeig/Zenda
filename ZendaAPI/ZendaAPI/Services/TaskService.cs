using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ZendaAPI.Connection;
using ZendaAPI.Interfaces;
using ZendaAPI.Models;
using ZendaAPI.Requests.Task;
using ZendaAPI.UniversalMethods;

namespace ZendaAPI.Services
{
    public class TaskService : ITaskService
    {
        private readonly ContextDb _context;
        private readonly RagClient _ragClient;
        private readonly IWebHostEnvironment _environment;
        private const int TaskStatusActive = 1;
        private const int TaskStatusDone = 2;
        private const int ProjectStatusActive = 1;
        private const int ProjectStatusArchived = 2;

        public TaskService(ContextDb context, RagClient ragClient, IWebHostEnvironment environment)
        {
            _context = context;
            _ragClient = ragClient;
            _environment = environment;
        }

        private static string IndexText(TaskItem task) =>
            $"Задача: {task.Title}" + (task.Comment != null ? $". {task.Comment}" : "");

        public async Task<IActionResult> GetAll(int userId)
        {
            var projects = await _context.Projects
                .Where(p => p.UserId == userId && p.StatusId == ProjectStatusActive)
                .Include(p => p.Tasks).ThenInclude(t => t.Attachments)
                .OrderBy(p => p.CreatedAt)
                .ToListAsync();

            var result = projects.Select(p => new
            {
                p.Id,
                p.Name,
                p.Deadline,
                Tasks = p.Tasks.OrderBy(t => t.Id).Select(t => new
                {
                    t.Id,
                    t.Title,
                    t.Comment,
                    t.Address,
                    t.DueDate,
                    t.DueTime,
                    Done = t.StatusId == TaskStatusDone,
                    Attachments = t.Attachments.Select(a => new { a.Id, a.Label, a.Url, a.TypeId })
                })
            });

            return new OkObjectResult(new { status = true, message = "Успешно", data = result });
        }

        public async Task<IActionResult> GetOverdue(int userId, DateTime before)
        {
            var day = before.Date;

            var tasks = await _context.TaskItems
                .Include(t => t.Project)
                .Include(t => t.Attachments)
                .Where(t => t.Project.UserId == userId
                    && t.Project.StatusId == ProjectStatusActive
                    && t.StatusId != TaskStatusDone
                    && t.DueDate != null
                    && t.DueDate.Value.Date < day)
                .OrderBy(t => t.DueDate)
                .ThenBy(t => t.DueTime)
                .ToListAsync();

            var data = tasks.Select(t => new
            {
                type = "task",
                t.Id,
                t.Title,
                t.Comment,
                t.Address,
                t.DueDate,
                StartTime = t.DueTime,
                EndTime = (TimeSpan?)null,
                Done = false,
                Overdue = true,
                ProjectName = t.Project.Name,
                Attachments = t.Attachments.Select(a => new { a.Id, a.Label, a.Url, a.TypeId })
            }).ToList();

            return new OkObjectResult(new { status = true, message = "Успешно", data });
        }

        public async Task<IActionResult> Create(int userId, CreateTaskModel model)
        {
            var project = await _context.Projects.FirstOrDefaultAsync(p => p.Id == model.ProjectId && p.UserId == userId);
            if (project == null)
                return new NotFoundObjectResult(new { status = false, message = "Проект не найден", data = (object)null });

            var task = new TaskItem
            {
                ProjectId = model.ProjectId,
                Title = model.Title,
                Comment = model.Comment,
                Address = model.Address,
                DueDate = model.DueDate,
                DueTime = model.DueTime,
                StatusId = TaskStatusActive
            };

            _context.TaskItems.Add(task);
            await _context.SaveChangesAsync();
            await _ragClient.IndexAsync(userId, "task", task.Id, IndexText(task));

            return new OkObjectResult(new { status = true, message = "Задача создана", data = new { task.Id } });
        }

        public async Task<IActionResult> Update(int userId, int taskId, UpdateTaskModel model)
        {
            var task = await _context.TaskItems
                .Include(t => t.Project)
                .FirstOrDefaultAsync(t => t.Id == taskId && t.Project.UserId == userId);

            if (task == null)
                return new NotFoundObjectResult(new { status = false, message = "Задача не найдена", data = (object)null });

            task.Title = model.Title;
            task.Comment = model.Comment;
            task.Address = model.Address;
            task.DueDate = model.DueDate;
            task.DueTime = model.DueTime;
            await _context.SaveChangesAsync();
            await _ragClient.IndexAsync(userId, "task", task.Id, IndexText(task));

            return new OkObjectResult(new { status = true, message = "Обновлено", data = (object)null });
        }

        public async Task<IActionResult> Complete(int userId, int taskId)
        {
            var task = await _context.TaskItems
                .Include(t => t.Project)
                .ThenInclude(p => p.Tasks)
                .FirstOrDefaultAsync(t => t.Id == taskId && t.Project.UserId == userId);

            if (task == null)
                return new NotFoundObjectResult(new { status = false, message = "Задача не найдена", data = (object)null });

            task.StatusId = TaskStatusDone;
            task.CompletedAt = DateTime.UtcNow;

            var allDone = task.Project.Tasks.All(t => t.Id == task.Id || t.StatusId == TaskStatusDone);
            var justArchived = false;

            if (allDone)
            {
                task.Project.StatusId = ProjectStatusArchived;
                task.Project.ArchivedAt = DateTime.UtcNow;
                justArchived = true;
            }

            await _context.SaveChangesAsync();

            return new OkObjectResult(new { status = true, message = "Задача выполнена", data = new { projectArchived = justArchived } });
        }

        public async Task<IActionResult> Delete(int userId, int taskId)
        {
            var task = await _context.TaskItems
                .Include(t => t.Project)
                .FirstOrDefaultAsync(t => t.Id == taskId && t.Project.UserId == userId);

            if (task == null)
                return new NotFoundObjectResult(new { status = false, message = "Задача не найдена", data = (object)null });

            var notes = await _context.Notes.Where(n => n.TaskItemId == task.Id).ToListAsync();
            var attachments = await _context.Attachments.Where(a => a.TaskItemId == task.Id).ToListAsync();
            _context.Notes.RemoveRange(notes);
            _context.Attachments.RemoveRange(attachments);
            _context.TaskItems.Remove(task);
            await _context.SaveChangesAsync();

            foreach (var attachment in attachments)
            {
                AttachmentStorage.DeleteFile(_environment.ContentRootPath, attachment.Url);
                await _ragClient.DeleteIndexAsync(userId, "attachment", attachment.Id);
            }

            await _ragClient.DeleteIndexAsync(userId, "task", taskId);
            foreach (var note in notes)
                await _ragClient.DeleteIndexAsync(userId, "note", note.Id);

            return new OkObjectResult(new { status = true, message = "Задача удалена", data = (object)null });
        }
    }
}