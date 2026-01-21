using System.ComponentModel.DataAnnotations;

namespace AnimalFostering.API.Models
{
    public class Shelter
    {
        public int Id { get; set; }
        
        [Required]
        public string Name { get; set; } = string.Empty;
        
        [Required]
        public string Address { get; set; } = string.Empty;
        
        public string? City { get; set; }
        public string? Phone { get; set; }
        public string? Email { get; set; }
        
        public double? Latitude { get; set; }
        public double? Longitude { get; set; }
        
        public string? Description { get; set; }
        
        // Add these new properties for Google Places integration
        public double? Rating { get; set; }
        public string? GooglePlaceId { get; set; }
        public string? Website { get; set; }
        public string? OpeningHours { get; set; }
        public bool? IsOpenNow { get; set; }

        public bool IsActive { get; set; } = true;

        // Add this for distinguishing between local and Google Places data
        public string? Source { get; set; } = "Local"; // "Local" or "GooglePlaces"
        
        // Add timestamps if not already present
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}
