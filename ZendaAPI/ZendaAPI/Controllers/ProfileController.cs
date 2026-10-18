using Microsoft.AspNetCore.Mvc;
using ZendaAPI.CustomAttributes;
using ZendaAPI.Interfaces;
using ZendaAPI.Requests.Profile;

namespace ZendaAPI.Controllers
{
    [ApiController]
    [Route("profile")]
    [SessionAuthorize]
    public class ProfileController : BaseController
    {
        private readonly IProfileService _profileService;

        public ProfileController(IProfileService profileService)
        {
            _profileService = profileService;
        }

        [HttpGet]
        public async Task<IActionResult> Get() => await _profileService.Get(CurrentUserId);

        [HttpPut]
        public async Task<IActionResult> Update([FromBody] UpdateProfileModel model) => await _profileService.Update(CurrentUserId, model);

        [HttpPut("language")]
        public async Task<IActionResult> UpdateLanguage([FromBody] UpdateLanguageModel model) =>
            await _profileService.UpdateLanguage(CurrentUserId, model);

        [HttpPost("avatar")]
        [RequestSizeLimit(6_000_000)]
        public async Task<IActionResult> UploadAvatar(IFormFile? file) => await _profileService.UploadAvatar(CurrentUserId, file);
    }
}