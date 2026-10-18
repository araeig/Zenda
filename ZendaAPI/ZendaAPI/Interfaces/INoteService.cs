using Microsoft.AspNetCore.Mvc;
using ZendaAPI.Requests.Note;

namespace ZendaAPI.Interfaces
{
    public interface INoteService
    {
        Task<IActionResult> GetAll(int userId, int? taskItemId, int? eventId);
        Task<IActionResult> Create(int userId, CreateNoteModel model);
        Task<IActionResult> Update(int userId, int noteId, UpdateNoteModel model);
        Task<IActionResult> Delete(int userId, int noteId);
    }
}