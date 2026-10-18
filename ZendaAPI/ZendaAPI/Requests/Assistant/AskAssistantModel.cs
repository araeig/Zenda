using System.ComponentModel.DataAnnotations;

namespace ZendaAPI.Requests.Assistant
{
    public class AskAssistantModel
    {
        [Required(ErrorMessage = "Укажите вопрос")]
        [StringLength(1000, ErrorMessage = "Вопрос не длиннее 1000 символов")]
        public string Question { get; set; }
    }
}