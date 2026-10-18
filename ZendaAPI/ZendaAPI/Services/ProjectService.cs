using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ZendaAPI.Connection;
using ZendaAPI.Interfaces;
using ZendaAPI.Models;
using ZendaAPI.Requests.Project;

namespace ZendaAPI.Services
{
    public class ProjectService : IProjectService
    {
        private readonly ContextDb _context;
        private const int StatusActive = 1;
        private const int StatusArchived = 2;
        private const int TaskStatusDone = 2;

        public ProjectService(ContextDb context)
        {
            _context = context;
        }

        private async Task<object> BuildCard(Project p)
        {
            var tasks = await _context.TaskItems.Where(t => t.ProjectId == p.Id).ToListAsync();
            var total = tasks.Count;
            var done = tasks.Count(t => t.StatusId == TaskStatusDone);

            return new
            {
                p.Id,
                p.Name,
                p.Deadline,
                p.CreatedAt,
                total,
                done,
                remaining = total - done,
                progressPercent = total == 0 ? 0 : (int)Math.Round(done * 100.0 / total)
            };
        }

        public async Task<IActionResult> GetHome(int userId)
        {
            var projects = await _context.Projects
                .Where(p => p.UserId == userId && p.StatusId == StatusActive)
                .ToListAsync();

            var weekAhead = DateTime.UtcNow.Date.AddDays(7);

            var urgentProjects = projects
                .Where(p => p.Deadline != null && p.Deadline.Value.Date <= weekAhead)
                .OrderBy(p => p.Deadline)
                .ToList();

            var otherProjects = projects
                .Except(urgentProjects)
                .OrderBy(p => p.CreatedAt)
                .ToList();

            var urgent = new List<object>();
            foreach (var p in urgentProjects) urgent.Add(await BuildCard(p));

            var others = new List<object>();
            foreach (var p in otherProjects) others.Add(await BuildCard(p));

            return new OkObjectResult(new
            {
                status = true,
                message = "Успешно",
                data = new { urgent, others, hasUrgent = urgent.Count > 0 }
            });
        }

        public async Task<IActionResult> GetArchive(int userId)
        {
            var projects = await _context.Projects
                .Where(p => p.UserId == userId && p.StatusId == StatusArchived)
                .Include(p => p.Tasks)
                .ToListAsync();

            var result = projects
                .OrderByDescending(p => p.ArchivedAt ?? p.CreatedAt)
                .Select(p => new
                {
                    p.Id,
                    p.Name,
                    CompletedAt = p.ArchivedAt ?? (p.Tasks.Any() ? p.Tasks.Max(t => t.CreatedAt) : p.CreatedAt),
                    Tasks = p.Tasks.OrderBy(t => t.Id).Select(t => new { t.Id, t.Title }).ToList()
                });

            return new OkObjectResult(new { status = true, message = "Успешно", data = result });
        }

        public async Task<IActionResult> Create(int userId, CreateProjectModel model)
        {
            var project = new Project
            {
                UserId = userId,
                Name = model.Name,
                Deadline = model.Deadline,
                StatusId = StatusActive
            };

            _context.Projects.Add(project);
            await _context.SaveChangesAsync();

            return new OkObjectResult(new { status = true, message = "Проект создан", data = new { project.Id } });
        }

        public async Task<IActionResult> Update(int userId, int projectId, UpdateProjectModel model)
        {
            var project = await _context.Projects.FirstOrDefaultAsync(p => p.Id == projectId && p.UserId == userId);
            if (project == null)
                return new NotFoundObjectResult(new { status = false, message = "Проект не найден", data = (object)null });

            project.Name = model.Name;
            project.Deadline = model.Deadline;
            await _context.SaveChangesAsync();

            return new OkObjectResult(new { status = true, message = "Обновлено", data = (object)null });
        }

        public async Task<IActionResult> Restore(int userId, int projectId)
        {
            var project = await _context.Projects.FirstOrDefaultAsync(p => p.Id == projectId && p.UserId == userId);
            if (project == null)
                return new NotFoundObjectResult(new { status = false, message = "Проект не найден", data = (object)null });

            project.StatusId = StatusActive;
            project.ArchivedAt = null;
            await _context.SaveChangesAsync();

            return new OkObjectResult(new { status = true, message = "Проект восстановлен", data = (object)null });
        }
    }
}