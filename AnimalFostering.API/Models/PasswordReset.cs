using System.ComponentModel.DataAnnotations;

namespace AnimalFostering.API.Models
{
    public class PasswordReset
    {
        public int Id { get; set; }
        
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;
        
        [Required]
        public string Token { get; set; } = string.Empty;
        
        [Required]
        public string ResetCode { get; set; } = string.Empty;
        
        public DateTime ExpiresAt { get; set; }
        
        public bool IsUsed { get; set; }
        
        public DateTime CreatedAt { get; set; }
    }
}