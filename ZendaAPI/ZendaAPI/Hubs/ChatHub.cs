using System.Text;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using ZendaAPI.Connection;
using ZendaAPI.Interfaces;
using ZendaAPI.UniversalMethods;

namespace ZendaAPI.Hubs
{
    public class ChatHub : Hub
    {
        private readonly ContextDb _context;
        private readonly IAssistantService _assistantService;
        private readonly RagClient _ragClient;

        public ChatHub(ContextDb context, IAssistantService assistantService, RagClient ragClient)
        {
            _context = context;
            _assistantService = assistantService;
            _ragClient = ragClient;
        }

        public override async Task OnConnectedAsync()
        {
            var userId = await ResolveUserId();
            if (userId == null)
            {
                Context.Abort();
                return;
            }

            Context.Items["UserId"] = userId.Value;
            await base.OnConnectedAsync();
        }

        public async Task Ask(string question)
        {
            if (!Context.Items.TryGetValue("UserId", out var value) || value is not int userId)
            {
                await Clients.Caller.SendAsync("error", "Сессия недействительна или истекла");
                return;
            }

            var language = await _assistantService.UserLanguageAsync(userId);

            question = (question ?? "").Trim();
            if (question.Length == 0 || question.Length > 1000)
            {
                await Clients.Caller.SendAsync("error", Messages.Translate("Вопрос должен быть от 1 до 1000 символов", language));
                return;
            }

            var facts = await _assistantService.BuildFactsAsync(userId);
            var history = await _assistantService.RecentHistoryAsync(userId);
            var today = _assistantService.TodayText();
            var answer = new StringBuilder();
            List<RagSource>? rawSources = null;

            try
            {
                await foreach (var item in _ragClient.AskStreamAsync(userId, question, facts, today, history, language, Context.ConnectionAborted))
                {
                    switch (item.Type)
                    {
                        case "sources":
                            rawSources = item.Sources;
                            break;
                        case "token":
                            answer.Append(item.Text);
                            await Clients.Caller.SendAsync("token", item.Text);
                            break;
                        case "error":
                            Console.WriteLine($"RAG stream error: {item.Message}");
                            await Clients.Caller.SendAsync("error", Messages.Translate("Ассистент сейчас недоступен", language));
                            return;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"RAG stream error: {ex.Message}");
                await Clients.Caller.SendAsync("error", Messages.Translate("Ассистент сейчас недоступен", language));
                return;
            }

            var text = answer.ToString().Trim();
            if (text.Length == 0)
            {
                await Clients.Caller.SendAsync("error", Messages.Translate("Ассистент не смог ответить", language));
                return;
            }

            var sources = await _assistantService.BuildSourcesAsync(userId, text, rawSources);
            await _assistantService.SaveExchangeAsync(userId, question, text, sources);
            await Clients.Caller.SendAsync("done", sources);
        }

        private async Task<int?> ResolveUserId()
        {
            var http = Context.GetHttpContext();
            if (http == null) return null;

            var token = http.Request.Query["access_token"].ToString();
            if (string.IsNullOrEmpty(token))
            {
                var header = http.Request.Headers["Authorization"].ToString();
                if (header.StartsWith("Bearer ")) token = header.Substring("Bearer ".Length).Trim();
            }
            if (string.IsNullOrEmpty(token)) return null;

            var session = await _context.Sessions.FirstOrDefaultAsync(s => s.Token == token);
            if (session == null || session.ExpiresAt < DateTime.UtcNow) return null;

            return session.UserId;
        }
    }
}