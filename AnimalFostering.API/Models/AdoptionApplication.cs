using System.ComponentModel.DataAnnotations;

namespace AnimalFostering.API.Models
{
    public class AdoptionApplication
    {
        public int Id { get; set; }
        
        [Required]
        public int UserId { get; set; }
        
        [Required]
        public int AnimalId { get; set; }
        
        [Required]
        public string Status { get; set; } = "Pending"; // Pending, Approved, Rejected, Withdrawn
        
        public string? Message { get; set; }
        public string? AdminNotes { get; set; }
        
        [Required]
        public DateTime ApplicationDate { get; set; } = DateTime.UtcNow;
        
        public DateTime? ReviewedDate { get; set; }
        public int? ReviewedByAdminId { get; set; }

        // Navigation properties
        public User User { get; set; } = null!;
        public Animal Animal { get; set; } = null!;
        public User? ReviewedByAdmin { get; set; }
    }
}