using Microsoft.AspNetCore.Mvc;
using ZendaAPI.CustomAttributes;
using ZendaAPI.Interfaces;
using ZendaAPI.Requests.Auth;

namespace ZendaAPI.Controllers
{
    [ApiController]
    [Route("auth")]
    public class AuthController : BaseController
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("signup")]
        public async Task<IActionResult> SignUp([FromBody] SignUpModel model) => await _authService.SignUp(model);

        [HttpPost("signin")]
        public async Task<IActionResult> SignIn([FromBody] SignInModel model) => await _authService.SignIn(model);

        [SessionAuthorize]
        [HttpGet("me")]
        public async Task<IActionResult> Me() => await _authService.GetMe(CurrentUserId);

        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordModel model) => await _authService.ForgotPassword(model);

        [HttpGet("reset-password")]
        public async Task<IActionResult> ResetPasswordPage([FromQuery] string token, [FromQuery] string? lang) =>
            await _authService.ResetPasswordPage(token, lang);

        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromForm] ResetPasswordModel model) => await _authService.ResetPassword(model);
    }
}