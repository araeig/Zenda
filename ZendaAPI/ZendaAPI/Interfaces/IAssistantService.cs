using Microsoft.AspNetCore.Mvc;
using ZendaAPI.Models;
using ZendaAPI.Requests.Assistant;
using ZendaAPI.UniversalMethods;

namespace ZendaAPI.Interfaces
{
    public interface IAssistantService
    {
        Task<IActionResult> Ask(int userId, AskAssistantModel model);
        Task<IActionResult> GetHistory(int userId);
        Task<IActionResult> ClearHistory(int userId);
        Task<IActionResult> Transcribe(int userId, IFormFile? file);
        Task<IActionResult> GetSource(int userId, string type, int id);
        Task<string> BuildFactsAsync(int userId);
        Task<List<object>> RecentHistoryAsync(int userId);
        Task<string> UserLanguageAsync(int userId);
        string TodayText();
        Task<List<ChatSource>> BuildSourcesAsync(int userId, string answer, List<RagSource>? raw);
        Task<List<ChatSource>> ResolveSourcesAsync(int userId, List<RagSource>? raw);
        Task SaveExchangeAsync(int userId, string question, string answer, List<ChatSource> sources);
    }
}