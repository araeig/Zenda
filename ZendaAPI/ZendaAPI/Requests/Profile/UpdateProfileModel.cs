using System.ComponentModel.DataAnnotations;

namespace ZendaAPI.Requests.Profile
{
    public class UpdateProfileModel
    {
        [Required(ErrorMessage = "Укажите имя")]
        [StringLength(100, ErrorMessage = "Имя не длиннее 100 символов")]
        public string FirstName { get; set; }

        [Required(ErrorMessage = "Укажите фамилию")]
        [StringLength(100, ErrorMessage = "Фамилия не длиннее 100 символов")]
        public string LastName { get; set; }

        [StringLength(200, ErrorMessage = "Место учёбы или работы — не длиннее 200 символов")]
        public string? Workplace { get; set; }
    }
}