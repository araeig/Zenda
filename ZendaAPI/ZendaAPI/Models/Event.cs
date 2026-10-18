using System.Net.Mail;

namespace ZendaAPI.Models
{
    public class Event
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public User User { get; set; }
        public string Title { get; set; }
        public string? Comment { get; set; }
        public string? Address { get; set; }
        public DateTime Date { get; set; }
        public TimeSpan? StartTime { get; set; }
        public TimeSpan? EndTime { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public ICollection<Attachment> Attachments { get; set; } = new List<Attachment>();
    }
}