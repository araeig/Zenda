using System.ComponentModel.DataAnnotations;

namespace ZendaAPI.Requests.Project
{
    public class UpdateProjectModel
    {
        [Required(ErrorMessage = "Укажите название проекта")]
        [StringLength(200, ErrorMessage = "Название не длиннее 200 символов")]
        public string Name { get; set; }

        public DateTime? Deadline { get; set; }
    }
}