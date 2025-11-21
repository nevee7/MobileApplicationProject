namespace AnimalFostering.API.Models
{
    public class Animal
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Species { get; set; } = string.Empty;
        public string Breed { get; set; } = string.Empty;
        public int Age { get; set; }
        public string Gender { get; set; } = "Unknown";
        public string? Size { get; set; }
        public string Description { get; set; } = string.Empty;
        public string? MedicalNotes { get; set; }
        public string Status { get; set; } = "available";
        public string? ImageUrl { get; set; }
        public int? ShelterId { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}