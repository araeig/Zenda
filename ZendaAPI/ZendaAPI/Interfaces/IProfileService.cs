using Microsoft.AspNetCore.Mvc;
using ZendaAPI.Requests.Profile;

namespace ZendaAPI.Interfaces
{
    public interface IProfileService
    {
        Task<IActionResult> Get(int userId);
        Task<IActionResult> Update(int userId, UpdateProfileModel model);
        Task<IActionResult> UpdateLanguage(int userId, UpdateLanguageModel model);
        Task<IActionResult> UploadAvatar(int userId, IFormFile? file);
    }
}