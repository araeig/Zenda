using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ZendaAPI.Connection;
using ZendaAPI.Interfaces;
using ZendaAPI.Requests.Note;
using ZendaAPI.UniversalMethods;
using NoteModel = ZendaAPI.Models.Note;

namespace ZendaAPI.Services
{
    public class NoteService : INoteService
    {
        private readonly ContextDb _context;
        private readonly RagClient _ragClient;

        public NoteService(ContextDb context, RagClient ragClient)
        {
            _context = context;
            _ragClient = ragClient;
        }

        private async Task<bool> LinksAreValid(int userId, int? taskItemId, int? eventId)
        {
            if (taskItemId.HasValue)
            {
                var owns = await _context.TaskItems
                    .Include(t => t.Project)
                    .AnyAsync(t => t.Id == taskItemId && t.Project.UserId == userId);
                if (!owns) return false;
            }

            if (eventId.HasValue)
            {
                var owns = await _context.Events.AnyAsync(e => e.Id == eventId && e.UserId == userId);
                if (!owns) return false;
            }

            return true;
        }

        private async Task<string> IndexText(NoteModel note)
        {
            string? owner = null;
            if (note.TaskItemId.HasValue)
            {
                var title = await _context.TaskItems
                    .Where(t => t.Id == note.TaskItemId)
                    .Select(t => t.Title)
                    .FirstOrDefaultAsync();
                if (title != null) owner = $"к задаче «{title}»";
            }
            else if (note.EventId.HasValue)
            {
                var title = await _context.Events
                    .Where(e => e.Id == note.EventId)
                    .Select(e => e.Title)
                    .FirstOrDefaultAsync();
                if (title != null) owner = $"к событию «{title}»";
            }

            var prefix = owner == null ? "Заметка" : $"Заметка {owner}";
            return $"{prefix}: {note.Title}. {note.Content}";
        }

        public async Task<IActionResult> GetAll(int userId, int? taskItemId, int? eventId)
        {
            var query = _context.Notes.Where(n => n.UserId == userId);
            if (taskItemId.HasValue) query = query.Where(n => n.TaskItemId == taskItemId);
            if (eventId.HasValue) query = query.Where(n => n.EventId == eventId);

            var notes = await query
                .OrderByDescending(n => n.CreatedAt)
                .Select(n => new { n.Id, n.Title, n.Content, n.TaskItemId, n.EventId, n.CreatedAt })
                .ToListAsync();

            return new OkObjectResult(new { status = true, message = "Успешно", data = notes });
        }

        public async Task<IActionResult> Create(int userId, CreateNoteModel model)
        {
            if (!await LinksAreValid(userId, model.TaskItemId, model.EventId))
                return new BadRequestObjectResult(new { status = false, message = "Задача или событие не найдены", data = (object)null });

            var note = new NoteModel
            {
                UserId = userId,
                Title = model.Title.Trim(),
                Content = model.Content.Trim(),
                TaskItemId = model.TaskItemId,
                EventId = model.EventId
            };

            _context.Notes.Add(note);
            await _context.SaveChangesAsync();
            await _ragClient.IndexAsync(userId, "note", note.Id, await IndexText(note));

            return new OkObjectResult(new { status = true, message = "Заметка создана", data = new { note.Id } });
        }

        public async Task<IActionResult> Update(int userId, int noteId, UpdateNoteModel model)
        {
            var note = await _context.Notes.FirstOrDefaultAsync(n => n.Id == noteId && n.UserId == userId);
            if (note == null)
                return new NotFoundObjectResult(new { status = false, message = "Заметка не найдена", data = (object)null });

            if (!await LinksAreValid(userId, model.TaskItemId, model.EventId))
                return new BadRequestObjectResult(new { status = false, message = "Задача или событие не найдены", data = (object)null });

            note.Title = model.Title.Trim();
            note.Content = model.Content.Trim();
            note.TaskItemId = model.TaskItemId;
            note.EventId = model.EventId;
            await _context.SaveChangesAsync();
            await _ragClient.IndexAsync(userId, "note", note.Id, await IndexText(note));

            return new OkObjectResult(new { status = true, message = "Обновлено", data = (object)null });
        }

        public async Task<IActionResult> Delete(int userId, int noteId)
        {
            var note = await _context.Notes.FirstOrDefaultAsync(n => n.Id == noteId && n.UserId == userId);
            if (note == null)
                return new NotFoundObjectResult(new { status = false, message = "Заметка не найдена", data = (object)null });

            _context.Notes.Remove(note);
            await _context.SaveChangesAsync();
            await _ragClient.DeleteIndexAsync(userId, "note", noteId);

            return new OkObjectResult(new { status = true, message = "Удалено", data = (object)null });
        }
    }
}