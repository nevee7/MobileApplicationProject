using System.ComponentModel.DataAnnotations;

namespace AnimalFostering.API.Models
{
    public class ReportDefinition
    {
        public int Id { get; set; }

        [Required]
        public string Name { get; set; } = string.Empty;

        public string? Description { get; set; }

        [Required]
        public string Metric { get; set; } = "ApplicationsSummary";

        public string? FiltersJson { get; set; }

        public int CreatedByUserId { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        public User CreatedByUser { get; set; } = null!;
    }
}
