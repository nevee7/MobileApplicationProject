namespace AnimalFostering.API.Models
{
    public class ChatMessage
    {
        public int Id { get; set; }
        public int SenderId { get; set; }
        public int? ReceiverId { get; set; } // Null for admin broadcasts
        public string MessageType { get; set; } = "Text"; // Text, Image, System
        public string Content { get; set; } = string.Empty;
        public string? ImageUrl { get; set; }
        public bool IsRead { get; set; }
        public DateTime SentAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public User Sender { get; set; } = null!;
        public User? Receiver { get; set; }
    }
}