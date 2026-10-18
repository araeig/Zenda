using System.ComponentModel.DataAnnotations;

namespace ZendaAPI.Requests.Profile
{
    public class UpdateLanguageModel
    {
        [Range(1, 4, ErrorMessage = "Неизвестный язык")]
        public int LanguageId { get; set; }
    }
}