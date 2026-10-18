using System.ComponentModel.DataAnnotations;

namespace ZendaAPI.Requests.Attachments
{
    public class AddLinkModel
    {
        public int? TaskItemId { get; set; }
        public int? EventId { get; set; }

        [Required(ErrorMessage = "Укажите ссылку")]
        [StringLength(2000, ErrorMessage = "Ссылка слишком длинная")]
        public string Url { get; set; }

        [StringLength(100, ErrorMessage = "Название не длиннее 100 символов")]
        public string? Label { get; set; }
    }
}