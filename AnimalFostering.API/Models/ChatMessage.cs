using System.ComponentModel.DataAnnotations;

namespace AnimalFostering.API.Models
{
    public class ChatMessage
    {
        public int Id { get; set; }
        
        [Required]
        public int SenderId { get; set; }
        
        public int? ReceiverId { get; set; }
        
        [Required]
        public string MessageType { get; set; } = "Text"; // Text, Image, System
        
        [Required]
        public string Content { get; set; } = string.Empty;
        
        public bool IsRead { get; set; }
        
        [Required]
        public DateTime SentAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public User Sender { get; set; } = null!;
        public User? Receiver { get; set; }
    }
}