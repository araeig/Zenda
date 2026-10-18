using System.ComponentModel.DataAnnotations;
using static System.Collections.Specialized.BitVector32;

namespace ZendaAPI.Models
{
    public class User
    {
        public int Id { get; set; }
        [Required]
        public string FirstName { get; set; }
        [Required]
        public string LastName { get; set; }
        [Required]
        public string Email { get; set; }
        [Required]
        public string PasswordHash { get; set; }
        public string? Workplace { get; set; }
        public string? AvatarUrl { get; set; }
        public int LanguageId { get; set; } = 1;
        public Language Language { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public ICollection<Session> Sessions { get; set; } = new List<Session>();
    }
}