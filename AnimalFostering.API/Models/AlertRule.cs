using System.ComponentModel.DataAnnotations;

namespace AnimalFostering.API.Models
{
    public class AlertRule
    {
        public int Id { get; set; }

        [Required]
        public string Name { get; set; } = string.Empty;

        [Required]
        public string Metric { get; set; } = "PendingApplications";

        [Required]
        public string Comparison { get; set; } = "GreaterThan";

        [Required]
        public int Threshold { get; set; }

        public bool IsActive { get; set; } = true;

        public int CreatedByUserId { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        public User CreatedByUser { get; set; } = null!;
    }
}
