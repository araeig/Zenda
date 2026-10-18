using Microsoft.AspNetCore.Mvc;

namespace ZendaAPI.Controllers
{
    public class BaseController : ControllerBase
    {
        protected int CurrentUserId => (int)HttpContext.Items["UserId"]!;
    }
}