using Microsoft.EntityFrameworkCore;
using ZendaAPI.Models;

namespace ZendaAPI.Connection
{
    public class ContextDb : DbContext
    {
        public ContextDb(DbContextOptions<ContextDb> options) : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<Session> Sessions { get; set; }
        public DbSet<PasswordResetToken> PasswordResetTokens { get; set; }
        public DbSet<Language> Languages { get; set; }
        public DbSet<Project> Projects { get; set; }
        public DbSet<ProjectStatus> ProjectStatuses { get; set; }
        public DbSet<TaskItem> TaskItems { get; set; }
        public DbSet<TaskItemStatus> TaskItemStatuses { get; set; }
        public DbSet<Event> Events { get; set; }
        public DbSet<Attachment> Attachments { get; set; }
        public DbSet<AttachmentType> AttachmentTypes { get; set; }
        public DbSet<Note> Notes { get; set; }
        public DbSet<ChatMessage> ChatMessages { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            modelBuilder.Entity<User>()
                .HasOne(u => u.Language)
                .WithMany()
                .HasForeignKey(u => u.LanguageId);

            modelBuilder.Entity<Session>()
                .HasOne(s => s.User)
                .WithMany(u => u.Sessions)
                .HasForeignKey(s => s.UserId);

            modelBuilder.Entity<PasswordResetToken>()
                .HasOne(p => p.User)
                .WithMany()
                .HasForeignKey(p => p.UserId);

            modelBuilder.Entity<Project>()
                .HasOne(p => p.User)
                .WithMany()
                .HasForeignKey(p => p.UserId);

            modelBuilder.Entity<Project>()
                .HasOne(p => p.Status)
                .WithMany()
                .HasForeignKey(p => p.StatusId);

            modelBuilder.Entity<TaskItem>()
                .HasOne(t => t.Project)
                .WithMany(p => p.Tasks)
                .HasForeignKey(t => t.ProjectId);

            modelBuilder.Entity<TaskItem>()
                .HasOne(t => t.Status)
                .WithMany()
                .HasForeignKey(t => t.StatusId);

            modelBuilder.Entity<Event>()
                .HasOne(e => e.User)
                .WithMany()
                .HasForeignKey(e => e.UserId);

            modelBuilder.Entity<Attachment>()
                .HasOne(a => a.TaskItem)
                .WithMany(t => t.Attachments)
                .HasForeignKey(a => a.TaskItemId)
                .IsRequired(false);

            modelBuilder.Entity<Attachment>()
                .HasOne(a => a.Event)
                .WithMany(e => e.Attachments)
                .HasForeignKey(a => a.EventId)
                .IsRequired(false);

            modelBuilder.Entity<Attachment>()
                .HasOne(a => a.Type)
                .WithMany()
                .HasForeignKey(a => a.TypeId);

            modelBuilder.Entity<Note>()
                .HasOne(n => n.User)
                .WithMany()
                .HasForeignKey(n => n.UserId);

            modelBuilder.Entity<Note>()
                .HasOne(n => n.TaskItem)
                .WithMany()
                .HasForeignKey(n => n.TaskItemId)
                .IsRequired(false);

            modelBuilder.Entity<Note>()
                .HasOne(n => n.EventRef)
                .WithMany()
                .HasForeignKey(n => n.EventId)
                .IsRequired(false);

            modelBuilder.Entity<ChatMessage>()
                .HasOne(c => c.User)
                .WithMany()
                .HasForeignKey(c => c.UserId);

            modelBuilder.Entity<Language>().HasData(
                new Language { Id = 1, Code = "ru", Name = "Русский" },
                new Language { Id = 2, Code = "en", Name = "English" },
                new Language { Id = 3, Code = "zh", Name = "中文" },
                new Language { Id = 4, Code = "ar", Name = "العربية" }
            );

            modelBuilder.Entity<ProjectStatus>().HasData(
                new ProjectStatus { Id = 1, Name = "Активен" },
                new ProjectStatus { Id = 2, Name = "Архив" }
            );

            modelBuilder.Entity<TaskItemStatus>().HasData(
                new TaskItemStatus { Id = 1, Name = "Активна" },
                new TaskItemStatus { Id = 2, Name = "Выполнена" }
            );

            modelBuilder.Entity<AttachmentType>().HasData(
                new AttachmentType { Id = 1, Name = "Видео" },
                new AttachmentType { Id = 2, Name = "Документ" },
                new AttachmentType { Id = 3, Name = "Файл" },
                new AttachmentType { Id = 4, Name = "Ссылка" }
            );

            var utcConverter = new Microsoft.EntityFrameworkCore.Storage.ValueConversion.ValueConverter<DateTime, DateTime>(
                v => DateTime.SpecifyKind(v, DateTimeKind.Utc),
                v => DateTime.SpecifyKind(v, DateTimeKind.Utc));

            var nullableUtcConverter = new Microsoft.EntityFrameworkCore.Storage.ValueConversion.ValueConverter<DateTime?, DateTime?>(
                v => v.HasValue ? DateTime.SpecifyKind(v.Value, DateTimeKind.Utc) : v,
                v => v.HasValue ? DateTime.SpecifyKind(v.Value, DateTimeKind.Utc) : v);

            foreach (var entityType in modelBuilder.Model.GetEntityTypes())
            {
                foreach (var property in entityType.GetProperties())
                {
                    if (property.ClrType == typeof(DateTime))
                        property.SetValueConverter(utcConverter);
                    else if (property.ClrType == typeof(DateTime?))
                        property.SetValueConverter(nullableUtcConverter);
                }
            }

            base.OnModelCreating(modelBuilder);
        }
    }
}