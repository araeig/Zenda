using System.ComponentModel.DataAnnotations;

namespace ZendaAPI.Requests.Task
{
    public class UpdateTaskModel
    {
        [Required(ErrorMessage = "Укажите название задачи")]
        [StringLength(200, ErrorMessage = "Название не длиннее 200 символов")]
        public string Title { get; set; }

        [StringLength(2000, ErrorMessage = "Комментарий не длиннее 2000 символов")]
        public string? Comment { get; set; }

        [StringLength(300, ErrorMessage = "Адрес не длиннее 300 символов")]
        public string? Address { get; set; }

        public DateTime? DueDate { get; set; }
        public TimeSpan? DueTime { get; set; }
    }
}