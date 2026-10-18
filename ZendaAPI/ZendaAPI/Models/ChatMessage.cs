namespace ZendaAPI.Models
{
    public class ChatMessage
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public User User { get; set; }
        public string Role { get; set; }
        public string Content { get; set; }
        public string? SourcesJson { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}