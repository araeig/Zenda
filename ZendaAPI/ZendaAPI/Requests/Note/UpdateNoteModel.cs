using System.ComponentModel.DataAnnotations;

namespace ZendaAPI.Requests.Note
{
    public class UpdateNoteModel
    {
        [Required(ErrorMessage = "Укажите заголовок")]
        [StringLength(200, ErrorMessage = "Заголовок не длиннее 200 символов")]
        public string Title { get; set; }

        [Required(ErrorMessage = "Укажите содержание заметки")]
        [StringLength(5000, ErrorMessage = "Заметка не длиннее 5000 символов")]
        public string Content { get; set; }

        public int? TaskItemId { get; set; }
        public int? EventId { get; set; }
    }
}