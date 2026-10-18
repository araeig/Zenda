namespace ZendaAPI.Models
{
    public class TaskItem
    {
        public int Id { get; set; }
        public int ProjectId { get; set; }
        public Project Project { get; set; }
        public string Title { get; set; }
        public string? Comment { get; set; }
        public string? Address { get; set; }
        public DateTime? DueDate { get; set; }
        public TimeSpan? DueTime { get; set; }
        public int StatusId { get; set; }
        public TaskItemStatus Status { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? CompletedAt { get; set; }

        public ICollection<Attachment> Attachments { get; set; } = new List<Attachment>();
    }
}