namespace AnimalFostering.API.Models
{
    public class Notification
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public string Type { get; set; } = "Info"; // Info, Success, Warning, Error
        public bool IsRead { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public string? RelatedEntityType { get; set; } // Animal, Application, etc.
        public int? RelatedEntityId { get; set; }

        // Navigation properties
        public User User { get; set; } = null!;
    }
}