using System.Security.Cryptography;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ZendaAPI.Connection;
using ZendaAPI.Interfaces;
using ZendaAPI.Models;
using ZendaAPI.Requests.Auth;
using ZendaAPI.UniversalMethods;

namespace ZendaAPI.Services
{
    public class AuthService : IAuthService
    {
        private readonly ContextDb _context;
        private readonly IEmailService _emailService;
        private readonly IConfiguration _configuration;

        public AuthService(ContextDb context, IEmailService emailService, IConfiguration configuration)
        {
            _context = context;
            _emailService = emailService;
            _configuration = configuration;
        }

        public async Task<IActionResult> SignUp(SignUpModel model)
        {
            var exists = await _context.Users.AnyAsync(u => u.Email == model.Email);
            if (exists)
                return new BadRequestObjectResult(new { status = false, message = "Пользователь с таким email уже существует", data = (object)null });

            var user = new User
            {
                FirstName = model.FirstName,
                LastName = model.LastName,
                Email = model.Email,
                PasswordHash = PasswordService.HashPassword(model.Password),
                LanguageId = model.LanguageId is >= 1 and <= 4 ? model.LanguageId.Value : 1
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            var token = JwtGenerator.GenerateToken(user.Id, TimeSpan.FromDays(30));
            _context.Sessions.Add(new Session { UserId = user.Id, Token = token, ExpiresAt = DateTime.UtcNow.AddDays(30) });
            await _context.SaveChangesAsync();

            return new OkObjectResult(new { status = true, message = "Успешно", data = new { token, userId = user.Id } });
        }

        public async Task<IActionResult> SignIn(SignInModel model)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == model.Email);
            if (user == null || !PasswordService.VerifyPassword(model.Password, user.PasswordHash))
                return new UnauthorizedObjectResult(new { status = false, message = "Неверный email или пароль", data = (object)null });

            var token = JwtGenerator.GenerateToken(user.Id, TimeSpan.FromDays(30));
            _context.Sessions.Add(new Session { UserId = user.Id, Token = token, ExpiresAt = DateTime.UtcNow.AddDays(30) });
            await _context.SaveChangesAsync();

            return new OkObjectResult(new { status = true, message = "Успешно", data = new { token, userId = user.Id } });
        }

        public async Task<IActionResult> GetMe(int userId)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null)
                return new NotFoundObjectResult(new { status = false, message = "Пользователь не найден", data = (object)null });

            return new OkObjectResult(new
            {
                status = true,
                message = "Успешно",
                data = new { user.Id, user.FirstName, user.LastName, user.Email, user.Workplace, user.AvatarUrl, user.LanguageId }
            });
        }

        public async Task<IActionResult> ForgotPassword(ForgotPasswordModel model)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == model.Email);
            if (user != null)
            {
                var lang = ResetPasswordPages.Lang(Messages.CurrentLanguage);
                var token = Convert.ToHexString(RandomNumberGenerator.GetBytes(32));
                _context.PasswordResetTokens.Add(new PasswordResetToken
                {
                    UserId = user.Id,
                    Token = token,
                    ExpiresAt = DateTime.UtcNow.AddMinutes(30)
                });
                await _context.SaveChangesAsync();

                var link = $"{_configuration["App:PublicUrl"]}/auth/reset-password?token={token}&lang={lang}";
                try
                {
                    await _emailService.SendAsync(
                        user.Email,
                        ResetPasswordPages.EmailSubject(lang),
                        ResetPasswordPages.Email(user.FirstName, link, lang),
                        ResetPasswordPages.EmailImages());
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Email send error: {ex.Message}");
                    return new ObjectResult(new { status = false, message = "Не удалось отправить письмо", data = (object)null }) { StatusCode = 500 };
                }
            }

            return new OkObjectResult(new { status = true, message = "Если такой email зарегистрирован, письмо отправлено", data = (object)null });
        }

        public async Task<IActionResult> ResetPasswordPage(string token, string? lang)
        {
            var resetToken = await FindValidResetToken(token);
            if (resetToken == null)
                return Html(ResetPasswordPages.InvalidLink(lang));

            return Html(ResetPasswordPages.Form(token, null, lang));
        }

        public async Task<IActionResult> ResetPassword(ResetPasswordModel model)
        {
            var lang = model.Lang;
            var resetToken = await FindValidResetToken(model.Token);
            if (resetToken == null)
                return Html(ResetPasswordPages.InvalidLink(lang));

            if (string.IsNullOrEmpty(model.Password) || model.Password.Length < 8)
                return Html(ResetPasswordPages.Form(model.Token, ResetPasswordPages.T("errorShort", lang), lang));

            if (model.Password != model.ConfirmPassword)
                return Html(ResetPasswordPages.Form(model.Token, ResetPasswordPages.T("errorMismatch", lang), lang));

            resetToken.User.PasswordHash = PasswordService.HashPassword(model.Password);
            resetToken.IsUsed = true;
            _context.Sessions.RemoveRange(_context.Sessions.Where(s => s.UserId == resetToken.UserId));
            await _context.SaveChangesAsync();

            return Html(ResetPasswordPages.Done(lang));
        }

        private async Task<PasswordResetToken> FindValidResetToken(string token)
        {
            if (string.IsNullOrEmpty(token))
                return null;

            return await _context.PasswordResetTokens
                .Include(t => t.User)
                .FirstOrDefaultAsync(t => t.Token == token && !t.IsUsed && t.ExpiresAt > DateTime.UtcNow);
        }

        private static ContentResult Html(string html) =>
            new ContentResult { Content = html, ContentType = "text/html; charset=utf-8", StatusCode = 200 };
    }
}