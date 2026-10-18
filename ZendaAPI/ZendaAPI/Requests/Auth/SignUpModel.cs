using System.ComponentModel.DataAnnotations;

namespace ZendaAPI.Requests.Auth
{
    public class SignUpModel
    {
        [Required(ErrorMessage = "Укажите имя")]
        public string FirstName { get; set; }

        [Required(ErrorMessage = "Укажите фамилию")]
        public string LastName { get; set; }

        [Required(ErrorMessage = "Укажите email")]
        [EmailAddress(ErrorMessage = "Некорректный email")]
        public string Email { get; set; }

        [Required(ErrorMessage = "Укажите пароль")]
        [MinLength(8, ErrorMessage = "Пароль должен быть не короче 8 символов")]
        public string Password { get; set; }

        public int? LanguageId { get; set; }
    }
}