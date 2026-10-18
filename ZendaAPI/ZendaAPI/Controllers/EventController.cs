using Microsoft.AspNetCore.Mvc;
using ZendaAPI.CustomAttributes;
using ZendaAPI.Interfaces;
using ZendaAPI.Requests.Event;

namespace ZendaAPI.Controllers
{
    [ApiController]
    [Route("events")]
    [SessionAuthorize]
    public class EventController : BaseController
    {
        private readonly IEventService _eventService;

        public EventController(IEventService eventService)
        {
            _eventService = eventService;
        }

        [HttpGet]
        public async Task<IActionResult> GetByDate([FromQuery] DateTime date) => await _eventService.GetByDate(CurrentUserId, date);

        [HttpGet("range")]
        public async Task<IActionResult> GetRange([FromQuery] DateTime from, [FromQuery] DateTime to) =>
            await _eventService.GetRange(CurrentUserId, from, to);

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateEventModel model) => await _eventService.Create(CurrentUserId, model);

        [HttpPut("{eventId}")]
        public async Task<IActionResult> Update(int eventId, [FromBody] UpdateEventModel model) => await _eventService.Update(CurrentUserId, eventId, model);

        [HttpDelete("{eventId}")]
        public async Task<IActionResult> Delete(int eventId) => await _eventService.Delete(CurrentUserId, eventId);
    }
}