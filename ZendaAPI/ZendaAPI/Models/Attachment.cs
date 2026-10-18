namespace ZendaAPI.Models
{
    public class Attachment
    {
        public int Id { get; set; }
        public int? TaskItemId { get; set; }
        public TaskItem? TaskItem { get; set; }
        public int? EventId { get; set; }
        public Event? Event { get; set; }
        public int TypeId { get; set; }
        public AttachmentType Type { get; set; }
        public string Label { get; set; }
        public string Url { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}