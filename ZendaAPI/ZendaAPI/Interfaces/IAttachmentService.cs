using Microsoft.AspNetCore.Mvc;
using ZendaAPI.Requests.Attachments;

namespace ZendaAPI.Interfaces
{
    public interface IAttachmentService
    {
        Task<IActionResult> Upload(int userId, IFormFile? file, int? taskItemId, int? eventId, string? label);
        Task<IActionResult> AddLink(int userId, AddLinkModel model);
        Task<IActionResult> Delete(int userId, int attachmentId);
    }
}