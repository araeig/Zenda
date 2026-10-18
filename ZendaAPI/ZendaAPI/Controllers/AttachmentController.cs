using Microsoft.AspNetCore.Mvc;
using ZendaAPI.CustomAttributes;
using ZendaAPI.Interfaces;
using ZendaAPI.Requests.Attachments;

namespace ZendaAPI.Controllers
{
    [ApiController]
    [Route("attachments")]
    [SessionAuthorize]
    public class AttachmentController : BaseController
    {
        private readonly IAttachmentService _attachmentService;

        public AttachmentController(IAttachmentService attachmentService)
        {
            _attachmentService = attachmentService;
        }

        [HttpPost("upload")]
        [RequestSizeLimit(22_000_000)]
        public async Task<IActionResult> Upload(
            IFormFile? file,
            [FromForm] int? taskItemId,
            [FromForm] int? eventId,
            [FromForm] string? label) =>
            await _attachmentService.Upload(CurrentUserId, file, taskItemId, eventId, label);

        [HttpPost("link")]
        public async Task<IActionResult> AddLink([FromBody] AddLinkModel model) =>
            await _attachmentService.AddLink(CurrentUserId, model);

        [HttpDelete("{attachmentId:int}")]
        public async Task<IActionResult> Delete(int attachmentId) =>
            await _attachmentService.Delete(CurrentUserId, attachmentId);
    }
}