using System.ComponentModel.DataAnnotations;

namespace ZendaAPI.Requests.Auth
{
    public class SignInModel
    {
        [Required(ErrorMessage = "Укажите email")]
        public string Email { get; set; }

        [Required(ErrorMessage = "Укажите пароль")]
        public string Password { get; set; }
    }
}