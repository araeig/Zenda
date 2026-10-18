using Microsoft.AspNetCore.Mvc;
using ZendaAPI.Requests.Event;

namespace ZendaAPI.Interfaces
{
    public interface IEventService
    {
        Task<IActionResult> GetByDate(int userId, DateTime date);
        Task<IActionResult> GetRange(int userId, DateTime from, DateTime to);
        Task<IActionResult> Create(int userId, CreateEventModel model);
        Task<IActionResult> Update(int userId, int eventId, UpdateEventModel model);
        Task<IActionResult> Delete(int userId, int eventId);
    }
}