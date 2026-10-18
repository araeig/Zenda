using System.ComponentModel.DataAnnotations;

namespace ZendaAPI.Requests.Event
{
    public class UpdateEventModel
    {
        [Required(ErrorMessage = "Укажите название события")]
        [StringLength(200, ErrorMessage = "Название не длиннее 200 символов")]
        public string Title { get; set; }

        [StringLength(2000, ErrorMessage = "Комментарий не длиннее 2000 символов")]
        public string? Comment { get; set; }

        [StringLength(300, ErrorMessage = "Адрес не длиннее 300 символов")]
        public string? Address { get; set; }

        [Required(ErrorMessage = "Укажите дату")]
        public DateTime Date { get; set; }

        public TimeSpan? StartTime { get; set; }

        public TimeSpan? EndTime { get; set; }
    }
}