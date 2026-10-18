using Microsoft.AspNetCore.Mvc;
using ZendaAPI.CustomAttributes;
using ZendaAPI.Interfaces;
using ZendaAPI.Requests.Note;

namespace ZendaAPI.Controllers
{
    [ApiController]
    [Route("notes")]
    [SessionAuthorize]
    public class NoteController : BaseController
    {
        private readonly INoteService _noteService;

        public NoteController(INoteService noteService)
        {
            _noteService = noteService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll([FromQuery] int? taskItemId, [FromQuery] int? eventId) =>
            await _noteService.GetAll(CurrentUserId, taskItemId, eventId);

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateNoteModel model) => await _noteService.Create(CurrentUserId, model);

        [HttpPut("{noteId}")]
        public async Task<IActionResult> Update(int noteId, [FromBody] UpdateNoteModel model) => await _noteService.Update(CurrentUserId, noteId, model);

        [HttpDelete("{noteId}")]
        public async Task<IActionResult> Delete(int noteId) => await _noteService.Delete(CurrentUserId, noteId);
    }
}