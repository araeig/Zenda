namespace ZendaAPI.Models
{
    public class Note
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public User User { get; set; }
        public int? TaskItemId { get; set; }
        public TaskItem? TaskItem { get; set; }
        public int? EventId { get; set; }
        public Event? EventRef { get; set; }
        public string Title { get; set; }
        public string Content { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}