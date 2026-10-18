using System.Globalization;
using System.Text;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ZendaAPI.Connection;
using ZendaAPI.Interfaces;
using ZendaAPI.Models;
using ZendaAPI.Requests.Assistant;
using ZendaAPI.UniversalMethods;

namespace ZendaAPI.Services
{
    public class AssistantService : IAssistantService
    {
        private readonly ContextDb _context;
        private readonly RagClient _ragClient;
        private const int HistoryLimit = 100;
        private const int HistoryForModel = 6;
        private const int HistoryMessageMaxLength = 1500;
        private const int ProjectStatusActive = 1;
        private const int ProjectStatusArchived = 2;
        private const int TaskStatusDone = 2;
        private const int MentionedSourcesLimit = 6;
        private const int NoteSourcesLimit = 3;
        private const long MaxAudioSize = 25 * 1024 * 1024;
        private static readonly CultureInfo Ru = new("ru-RU");

        public AssistantService(ContextDb context, RagClient ragClient)
        {
            _context = context;
            _ragClient = ragClient;
        }

        public async Task<IActionResult> Ask(int userId, AskAssistantModel model)
        {
            var facts = await BuildFactsAsync(userId);
            var history = await RecentHistoryAsync(userId);
            var language = await UserLanguageAsync(userId);

            RagAskResult? result;
            try
            {
                result = await _ragClient.AskAsync(userId, model.Question, facts, TodayText(), history, language);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"RAG error: {ex.Message}");
                result = null;
            }

            if (result == null)
                return new ObjectResult(new { status = false, message = "Ассистент сейчас недоступен", data = (object)null }) { StatusCode = 503 };

            var sources = await BuildSourcesAsync(userId, result.Answer, result.Sources);
            await SaveExchangeAsync(userId, model.Question, result.Answer, sources);

            return new OkObjectResult(new
            {
                status = true,
                message = "Успешно",
                data = new { answer = result.Answer, sources }
            });
        }

        public async Task<IActionResult> Transcribe(int userId, IFormFile? file)
        {
            if (file == null || file.Length == 0)
                return new BadRequestObjectResult(new { status = false, message = "Запись пустая", data = (object)null });

            if (file.Length > MaxAudioSize)
                return new BadRequestObjectResult(new { status = false, message = "Запись слишком длинная", data = (object)null });

            var language = await UserLanguageAsync(userId);
            string? text;
            try
            {
                await using var stream = file.OpenReadStream();
                text = await _ragClient.TranscribeAsync(stream, file.FileName, file.ContentType, language);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Transcribe error: {ex.Message}");
                text = null;
            }

            if (text == null)
                return new ObjectResult(new { status = false, message = "Распознавание речи сейчас недоступно", data = (object)null }) { StatusCode = 503 };

            return new OkObjectResult(new { status = true, message = "Успешно", data = new { text } });
        }

        public async Task<IActionResult> GetHistory(int userId)
        {
            var messages = await _context.ChatMessages
                .Where(m => m.UserId == userId)
                .OrderByDescending(m => m.CreatedAt)
                .ThenByDescending(m => m.Id)
                .Take(HistoryLimit)
                .ToListAsync();

            var data = messages
                .OrderBy(m => m.CreatedAt)
                .ThenBy(m => m.Id)
                .Select(m => new
                {
                    m.Id,
                    m.Role,
                    m.Content,
                    m.CreatedAt,
                    Sources = string.IsNullOrEmpty(m.SourcesJson)
                        ? new List<ChatSource>()
                        : JsonSerializer.Deserialize<List<ChatSource>>(m.SourcesJson) ?? new List<ChatSource>()
                })
                .ToList();

            return new OkObjectResult(new { status = true, message = "Успешно", data });
        }

        public async Task<IActionResult> ClearHistory(int userId)
        {
            var messages = _context.ChatMessages.Where(m => m.UserId == userId);
            _context.ChatMessages.RemoveRange(messages);
            await _context.SaveChangesAsync();

            return new OkObjectResult(new { status = true, message = "История очищена", data = (object)null });
        }

        public async Task<IActionResult> GetSource(int userId, string type, int id)
        {
            var today = DateTime.Now.Date;

            switch (type)
            {
                case "task":
                    {
                        var t = await _context.TaskItems
                            .Include(x => x.Project)
                            .Include(x => x.Attachments)
                            .FirstOrDefaultAsync(x => x.Id == id && x.Project.UserId == userId);
                        if (t == null) break;

                        var done = t.StatusId == TaskStatusDone;
                        return SourceResult(new
                        {
                            kind = "item",
                            date = t.DueDate,
                            item = new
                            {
                                type = "task",
                                t.Id,
                                t.Title,
                                t.Comment,
                                t.Address,
                                StartTime = t.DueTime,
                                EndTime = (TimeSpan?)null,
                                Done = done,
                                ProjectName = (string?)t.Project.Name,
                                Overdue = !done && t.DueDate.HasValue && t.DueDate.Value.Date < today,
                                Attachments = t.Attachments.Select(a => new { a.Id, a.Label, a.Url, a.TypeId })
                            }
                        });
                    }
                case "event":
                    {
                        var e = await _context.Events
                            .Include(x => x.Attachments)
                            .FirstOrDefaultAsync(x => x.Id == id && x.UserId == userId);
                        if (e == null) break;

                        return SourceResult(new
                        {
                            kind = "item",
                            date = (DateTime?)e.Date,
                            item = new
                            {
                                type = "event",
                                e.Id,
                                e.Title,
                                e.Comment,
                                e.Address,
                                e.StartTime,
                                e.EndTime,
                                Done = false,
                                ProjectName = (string?)null,
                                Overdue = false,
                                Attachments = e.Attachments.Select(a => new { a.Id, a.Label, a.Url, a.TypeId })
                            }
                        });
                    }
                case "note":
                    {
                        var n = await _context.Notes.FirstOrDefaultAsync(x => x.Id == id && x.UserId == userId);
                        if (n == null) break;

                        string? ownerTitle = null;
                        if (n.TaskItemId != null)
                            ownerTitle = await _context.TaskItems.Where(x => x.Id == n.TaskItemId).Select(x => x.Title).FirstOrDefaultAsync();
                        else if (n.EventId != null)
                            ownerTitle = await _context.Events.Where(x => x.Id == n.EventId).Select(x => x.Title).FirstOrDefaultAsync();

                        return SourceResult(new
                        {
                            kind = "note",
                            note = new { n.Id, n.Title, n.Content, n.TaskItemId, n.EventId },
                            ownerTitle,
                            ownerIsTask = n.TaskItemId != null
                        });
                    }
                case "attachment":
                    {
                        var url = await _context.Attachments
                            .Where(x => x.Id == id
                                && ((x.TaskItem != null && x.TaskItem.Project.UserId == userId)
                                    || (x.Event != null && x.Event.UserId == userId)))
                            .Select(x => x.Url)
                            .FirstOrDefaultAsync();
                        if (url == null) break;

                        return SourceResult(new { kind = "attachment", url });
                    }
            }

            return new NotFoundObjectResult(new { status = false, message = "Источник не найден", data = (object)null });
        }

        private static IActionResult SourceResult(object data) =>
            new OkObjectResult(new { status = true, message = "Успешно", data });

        public async Task<List<object>> RecentHistoryAsync(int userId)
        {
            var recent = await _context.ChatMessages
                .Where(m => m.UserId == userId)
                .OrderByDescending(m => m.CreatedAt)
                .ThenByDescending(m => m.Id)
                .Take(HistoryForModel)
                .ToListAsync();

            return recent
                .OrderBy(m => m.CreatedAt)
                .ThenBy(m => m.Id)
                .Select(m => (object)new
                {
                    role = m.Role == "assistant" ? "assistant" : "user",
                    content = m.Content.Length > HistoryMessageMaxLength ? m.Content[..HistoryMessageMaxLength] : m.Content
                })
                .ToList();
        }

        public async Task<string> UserLanguageAsync(int userId)
        {
            var code = await _context.Users
                .Where(u => u.Id == userId)
                .Select(u => u.Language.Code)
                .FirstOrDefaultAsync();
            return code is "en" or "zh" or "ar" ? code : "ru";
        }

        public string TodayText() => DateTime.Now.ToString("dddd, d MMMM yyyy, HH:mm", Ru);

        private static string AttachmentTypeName(int typeId) => typeId switch
        {
            1 => "видео",
            2 => "документ",
            4 => "ссылка",
            _ => "файл"
        };

        private static string AttachmentsText(IEnumerable<Attachment> attachments)
        {
            var list = attachments.Select(a => $"«{a.Label}» ({AttachmentTypeName(a.TypeId)})").ToList();
            return list.Count == 0 ? "" : $" Вложения: {string.Join(", ", list)}.";
        }

        public async Task<string> BuildFactsAsync(int userId)
        {
            var today = DateTime.SpecifyKind(DateTime.Now.Date, DateTimeKind.Utc);
            var from = today.AddDays(-7);
            var to = today.AddDays(14);
            var urgentLimit = today.AddDays(7);

            var projects = await _context.Projects
                .Where(p => p.UserId == userId && p.StatusId == ProjectStatusActive)
                .Include(p => p.Tasks).ThenInclude(t => t.Attachments)
                .ToListAsync();

            var finished = await _context.Projects
                .Where(p => p.UserId == userId && p.StatusId == ProjectStatusArchived && p.ArchivedAt != null && p.ArchivedAt >= from)
                .OrderByDescending(p => p.ArchivedAt)
                .ToListAsync();

            var events = await _context.Events
                .Where(e => e.UserId == userId && e.Date >= from && e.Date <= to)
                .Include(e => e.Attachments)
                .OrderBy(e => e.Date)
                .ThenBy(e => e.StartTime)
                .ToListAsync();

            var sb = new StringBuilder();

            sb.AppendLine("Активные проекты:");
            if (projects.Count == 0) sb.AppendLine("• нет");
            foreach (var p in projects.OrderBy(p => p.Deadline ?? DateTime.MaxValue))
            {
                var total = p.Tasks.Count;
                var done = p.Tasks.Count(t => t.StatusId == TaskStatusDone);
                var deadline = p.Deadline.HasValue ? $"срок {FormatDate(p.Deadline.Value)}" : "без срока";
                var label = "";
                if (p.Deadline.HasValue)
                {
                    var deadlineDate = p.Deadline.Value.Date;
                    if (deadlineDate < today) label = " — горит, срок прошёл";
                    else if (deadlineDate <= urgentLimit) label = " — горит";
                }
                sb.AppendLine($"• «{p.Name}» — {deadline}, выполнено {done} из {total} задач{label}");
            }

            if (finished.Count > 0)
            {
                sb.AppendLine();
                sb.AppendLine("Недавно завершённые проекты:");
                foreach (var p in finished)
                    sb.AppendLine($"• «{p.Name}» — завершён {FormatDate(p.ArchivedAt!.Value)}");
            }

            var tasks = projects
                .SelectMany(p => p.Tasks.Select(t => new { Project = p.Name, Task = t }))
                .Where(x => x.Task.StatusId != TaskStatusDone
                    || (x.Task.DueDate.HasValue && x.Task.DueDate.Value.Date >= from && x.Task.DueDate.Value.Date <= to))
                .OrderBy(x => x.Task.StatusId == TaskStatusDone)
                .ThenBy(x => x.Task.DueDate ?? DateTime.MaxValue)
                .ThenBy(x => x.Task.DueTime)
                .Take(60)
                .ToList();

            sb.AppendLine();
            sb.AppendLine("Задачи:");
            if (tasks.Count == 0) sb.AppendLine("• нет");
            foreach (var x in tasks)
            {
                var t = x.Task;
                var when = t.DueDate.HasValue
                    ? $"срок {FormatDate(t.DueDate.Value)}{(t.DueTime.HasValue ? ", " + FormatTime(t.DueTime.Value) : "")}"
                    : "без срока";
                string status;
                if (t.StatusId == TaskStatusDone) status = "выполнена";
                else if (t.DueDate.HasValue && t.DueDate.Value.Date < today) status = "просрочена, не выполнена";
                else if (t.DueDate.HasValue && t.DueDate.Value.Date == today) status = "не выполнена, срок сегодня";
                else status = "не выполнена";
                var comment = string.IsNullOrWhiteSpace(t.Comment) ? "" : $" Комментарий: {t.Comment}";
                sb.AppendLine($"• «{t.Title}» (проект «{x.Project}») — {when} — {status}.{comment}{AttachmentsText(t.Attachments)}");
            }

            sb.AppendLine();
            sb.AppendLine("События с прошлой недели до двух недель вперёд:");
            if (events.Count == 0) sb.AppendLine("• нет");
            foreach (var e in events)
            {
                var time = e.StartTime.HasValue
                    ? FormatTime(e.StartTime.Value) + (e.EndTime.HasValue ? "–" + FormatTime(e.EndTime.Value) : "")
                    : "весь день";
                var place = string.IsNullOrWhiteSpace(e.Address) ? "" : $", {e.Address}";
                var comment = string.IsNullOrWhiteSpace(e.Comment) ? "" : $". Комментарий: {e.Comment}";
                sb.AppendLine($"• {FormatDate(e.Date)}, {time} — «{e.Title}»{place}{comment}{AttachmentsText(e.Attachments)}");
            }

            return sb.ToString().Trim();
        }

        public async Task<List<ChatSource>> BuildSourcesAsync(int userId, string answer, List<RagSource>? raw)
        {
            var today = DateTime.SpecifyKind(DateTime.Now.Date, DateTimeKind.Utc);
            var from = today.AddDays(-7);
            var to = today.AddDays(14);
            var text = (answer ?? "").ToLowerInvariant();

            var tasks = await _context.TaskItems
                .Where(t => t.Project.UserId == userId && t.Project.StatusId == ProjectStatusActive)
                .Select(t => new { t.Id, t.Title })
                .ToListAsync();

            var events = await _context.Events
                .Where(e => e.UserId == userId && e.Date >= from && e.Date <= to)
                .Select(e => new { e.Id, e.Title })
                .ToListAsync();

            var found = new List<(int Position, ChatSource Source)>();

            foreach (var t in tasks)
            {
                var position = FindTitle(text, t.Title);
                if (position >= 0)
                    found.Add((position, new ChatSource { Type = "task", Id = t.Id, Title = t.Title }));
            }

            foreach (var e in events)
            {
                var position = FindTitle(text, e.Title);
                if (position >= 0)
                    found.Add((position, new ChatSource { Type = "event", Id = e.Id, Title = e.Title }));
            }

            var sources = found
                .OrderBy(f => f.Position)
                .Select(f => f.Source)
                .DistinctBy(s => (s.Type, s.Title.Trim().ToLowerInvariant()))
                .Take(MentionedSourcesLimit)
                .ToList();

            var closeCandidates = raw?.Where(s => s.Type is "note" or "attachment").ToList();
            var close = await ResolveSourcesAsync(userId, closeCandidates);
            sources.AddRange(close.Take(NoteSourcesLimit));

            return sources;
        }

        public async Task<List<ChatSource>> ResolveSourcesAsync(int userId, List<RagSource>? raw)
        {
            var list = new List<ChatSource>();
            if (raw == null) return list;

            foreach (var source in raw.DistinctBy(s => (s.Type, s.Id)))
            {
                string? title = source.Type switch
                {
                    "task" => await _context.TaskItems
                        .Where(t => t.Id == source.Id && t.Project.UserId == userId)
                        .Select(t => t.Title)
                        .FirstOrDefaultAsync(),
                    "event" => await _context.Events
                        .Where(e => e.Id == source.Id && e.UserId == userId)
                        .Select(e => e.Title)
                        .FirstOrDefaultAsync(),
                    "note" => await _context.Notes
                        .Where(n => n.Id == source.Id && n.UserId == userId)
                        .Select(n => n.Title)
                        .FirstOrDefaultAsync(),
                    "attachment" => await _context.Attachments
                        .Where(a => a.Id == source.Id
                            && ((a.TaskItem != null && a.TaskItem.Project.UserId == userId)
                                || (a.Event != null && a.Event.UserId == userId)))
                        .Select(a => a.Label)
                        .FirstOrDefaultAsync(),
                    _ => null
                };

                if (title != null)
                    list.Add(new ChatSource { Type = source.Type, Id = source.Id, Title = title });
            }

            return list;
        }

        public async Task SaveExchangeAsync(int userId, string question, string answer, List<ChatSource> sources)
        {
            var now = DateTime.UtcNow;
            _context.ChatMessages.Add(new ChatMessage
            {
                UserId = userId,
                Role = "user",
                Content = question,
                CreatedAt = now
            });
            _context.ChatMessages.Add(new ChatMessage
            {
                UserId = userId,
                Role = "assistant",
                Content = answer,
                SourcesJson = sources.Count > 0 ? JsonSerializer.Serialize(sources) : null,
                CreatedAt = now.AddMilliseconds(1)
            });
            await _context.SaveChangesAsync();
        }

        private static int FindTitle(string text, string? title)
        {
            var value = (title ?? "").Trim().ToLowerInvariant();
            if (value.Length < 3) return -1;
            return text.IndexOf(value, StringComparison.Ordinal);
        }

        private static string FormatDate(DateTime date) => date.ToString("d MMMM (dddd)", Ru);

        private static string FormatTime(TimeSpan time) => time.ToString(@"hh\:mm");
    }
}