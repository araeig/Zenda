using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.EntityFrameworkCore;
using ZendaAPI.Connection;

namespace ZendaAPI.CustomAttributes
{
    public class SessionAuthorizeAttribute : Attribute, IAsyncActionFilter
    {
        public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
        {
            var authHeader = context.HttpContext.Request.Headers["Authorization"].ToString();
            if (string.IsNullOrEmpty(authHeader) || !authHeader.StartsWith("Bearer "))
            {
                context.Result = new UnauthorizedObjectResult(new { status = false, message = "Нет токена авторизации", data = (object)null });
                return;
            }

            var token = authHeader.Substring("Bearer ".Length).Trim();
            var db = context.HttpContext.RequestServices.GetRequiredService<ContextDb>();

            var session = await db.Sessions.FirstOrDefaultAsync(s => s.Token == token);
            if (session == null || session.ExpiresAt < DateTime.UtcNow)
            {
                context.Result = new UnauthorizedObjectResult(new { status = false, message = "Сессия недействительна или истекла", data = (object)null });
                return;
            }

            context.HttpContext.Items["UserId"] = session.UserId;
            await next();
        }
    }
}