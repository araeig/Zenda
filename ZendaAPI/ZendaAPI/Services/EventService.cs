using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ZendaAPI.Connection;
using ZendaAPI.Interfaces;
using ZendaAPI.Requests.Event;
using ZendaAPI.UniversalMethods;
using EventModel = ZendaAPI.Models.Event;

namespace ZendaAPI.Services
{
    public class EventService : IEventService
    {
        private readonly ContextDb _context;
        private readonly RagClient _ragClient;
        private readonly IWebHostEnvironment _environment;
        private const int ProjectStatusActive = 1;
        private const int TaskStatusDone = 2;

        public EventService(ContextDb context, RagClient ragClient, IWebHostEnvironment environment)
        {
            _context = context;
            _ragClient = ragClient;
            _environment = environment;
        }

        private static string IndexText(EventModel ev) =>
            $"Событие: {ev.Title}, {ev.Date:d MMMM}"
            + (ev.StartTime.HasValue ? $", {ev.StartTime}" : ", весь день")
            + (ev.Comment != null ? $". {ev.Comment}" : "");

        public async Task<IActionResult> GetByDate(int userId, DateTime date)
        {
            var day = date.Date;

            var events = await _context.Events
                .Where(e => e.UserId == userId && e.Date.Date == day)
                .Include(e => e.Attachments)
                .ToListAsync();

            var tasks = await _context.TaskItems
                .Include(t => t.Project)
                .Include(t => t.Attachments)
                .Where(t => t.Project.UserId == userId
                    && t.Project.StatusId == ProjectStatusActive
                    && t.DueDate != null
                    && t.DueDate.Value.Date == day)
                .ToListAsync();

            var items = new List<(TimeSpan? Time, object Item)>();

            foreach (var e in events)
                items.Add((e.StartTime, new
                {
                    type = "event",
                    e.Id,
                    e.Title,
                    e.Comment,
                    e.Address,
                    StartTime = e.StartTime,
                    e.EndTime,
                    Done = false,
                    ProjectName = (string?)null,
                    Attachments = e.Attachments.Select(a => new { a.Id, a.Label, a.Url, a.TypeId })
                }));

            foreach (var t in tasks)
                items.Add((t.DueTime, new
                {
                    type = "task",
                    t.Id,
                    t.Title,
                    t.Comment,
                    t.Address,
                    StartTime = t.DueTime,
                    EndTime = (TimeSpan?)null,
                    Done = t.StatusId == TaskStatusDone,
                    ProjectName = (string?)t.Project.Name,
                    Attachments = t.Attachments.Select(a => new { a.Id, a.Label, a.Url, a.TypeId })
                }));

            var data = items
                .OrderBy(i => i.Time.HasValue ? 1 : 0)
                .ThenBy(i => i.Time)
                .Select(i => i.Item)
                .ToList();

            return new OkObjectResult(new { status = true, message = "Успешно", data });
        }

        public async Task<IActionResult> GetRange(int userId, DateTime from, DateTime to)
        {
            var start = from.Date;
            var end = to.Date;

            var data = await _context.Events
                .Where(e => e.UserId == userId && e.Date.Date >= start && e.Date.Date <= end)
                .OrderBy(e => e.Date)
                .ThenBy(e => e.StartTime)
                .Select(e => new { e.Id, e.Title, e.Address, e.Date, e.StartTime, e.EndTime })
                .ToListAsync();

            return new OkObjectResult(new { status = true, message = "Успешно", data });
        }

        public async Task<IActionResult> Create(int userId, CreateEventModel model)
        {
            var ev = new EventModel
            {
                UserId = userId,
                Title = model.Title,
                Comment = model.Comment,
                Address = model.Address,
                Date = model.Date,
                StartTime = model.StartTime,
                EndTime = model.EndTime
            };

            _context.Events.Add(ev);
            await _context.SaveChangesAsync();
            await _ragClient.IndexAsync(userId, "event", ev.Id, IndexText(ev));

            return new OkObjectResult(new { status = true, message = "Событие создано", data = new { ev.Id } });
        }

        public async Task<IActionResult> Update(int userId, int eventId, UpdateEventModel model)
        {
            var ev = await _context.Events.FirstOrDefaultAsync(e => e.Id == eventId && e.UserId == userId);
            if (ev == null)
                return new NotFoundObjectResult(new { status = false, message = "Событие не найдено", data = (object)null });

            ev.Title = model.Title;
            ev.Comment = model.Comment;
            ev.Address = model.Address;
            ev.Date = model.Date;
            ev.StartTime = model.StartTime;
            ev.EndTime = model.EndTime;
            await _context.SaveChangesAsync();
            await _ragClient.IndexAsync(userId, "event", ev.Id, IndexText(ev));

            return new OkObjectResult(new { status = true, message = "Обновлено", data = (object)null });
        }

        public async Task<IActionResult> Delete(int userId, int eventId)
        {
            var ev = await _context.Events.FirstOrDefaultAsync(e => e.Id == eventId && e.UserId == userId);
            if (ev == null)
                return new NotFoundObjectResult(new { status = false, message = "Событие не найдено", data = (object)null });

            var notes = await _context.Notes.Where(n => n.EventId == ev.Id).ToListAsync();
            var attachments = await _context.Attachments.Where(a => a.EventId == ev.Id).ToListAsync();
            _context.Notes.RemoveRange(notes);
            _context.Attachments.RemoveRange(attachments);
            _context.Events.Remove(ev);
            await _context.SaveChangesAsync();

            foreach (var attachment in attachments)
            {
                AttachmentStorage.DeleteFile(_environment.ContentRootPath, attachment.Url);
                await _ragClient.DeleteIndexAsync(userId, "attachment", attachment.Id);
            }

            await _ragClient.DeleteIndexAsync(userId, "event", eventId);
            foreach (var note in notes)
                await _ragClient.DeleteIndexAsync(userId, "note", note.Id);

            return new OkObjectResult(new { status = true, message = "Удалено", data = (object)null });
        }
    }
}