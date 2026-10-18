using Microsoft.AspNetCore.Mvc;
using ZendaAPI.CustomAttributes;
using ZendaAPI.Interfaces;
using ZendaAPI.Requests.Assistant;

namespace ZendaAPI.Controllers
{
    [ApiController]
    [Route("ai")]
    [SessionAuthorize]
    public class AssistantController : BaseController
    {
        private readonly IAssistantService _assistantService;

        public AssistantController(IAssistantService assistantService)
        {
            _assistantService = assistantService;
        }

        [HttpPost("chat")]
        public async Task<IActionResult> Chat([FromBody] AskAssistantModel model) => await _assistantService.Ask(CurrentUserId, model);

        [HttpGet("history")]
        public async Task<IActionResult> GetHistory() => await _assistantService.GetHistory(CurrentUserId);

        [HttpDelete("history")]
        public async Task<IActionResult> ClearHistory() => await _assistantService.ClearHistory(CurrentUserId);

        [HttpGet("source/{type}/{id:int}")]
        public async Task<IActionResult> GetSource(string type, int id) =>
            await _assistantService.GetSource(CurrentUserId, type, id);

        [HttpPost("transcribe")]
        [RequestSizeLimit(26_000_000)]
        public async Task<IActionResult> Transcribe(IFormFile? file) => await _assistantService.Transcribe(CurrentUserId, file);
    }
}