using Microsoft.AspNetCore.Mvc;
using ZendaAPI.Requests.Auth;

namespace ZendaAPI.Interfaces
{
    public interface IAuthService
    {
        Task<IActionResult> SignUp(SignUpModel model);
        Task<IActionResult> SignIn(SignInModel model);
        Task<IActionResult> GetMe(int userId);
        Task<IActionResult> ForgotPassword(ForgotPasswordModel model);
        Task<IActionResult> ResetPasswordPage(string token, string? lang);
        Task<IActionResult> ResetPassword(ResetPasswordModel model);
    }
}