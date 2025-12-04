using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using AnimalFostering.API.Data;
using AnimalFostering.API.Models;
using Microsoft.AspNetCore.Authorization;
using System.Text.RegularExpressions;
using System.ComponentModel.DataAnnotations;

namespace AnimalFostering.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;

        public AuthController(AppDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        [HttpPost("register")]
        [AllowAnonymous]
        public async Task<ActionResult<AuthResponse>> Register(RegisterRequest request)
        {
            // Validate input
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            // Check if user already exists
            if (await _context.Users.AnyAsync(u => u.Email == request.Email))
            {
                return BadRequest(new { message = "User already exists with this email" });
            }

            // Validate email format
            if (!IsValidEmail(request.Email))
            {
                return BadRequest(new { message = "Invalid email format" });
            }

            // Validate password strength
            if (string.IsNullOrWhiteSpace(request.Password) || request.Password.Length < 6)
            {
                return BadRequest(new { message = "Password must be at least 6 characters long" });
            }

            // Create new user
            var user = new User
            {
                Email = request.Email.ToLower().Trim(),
                FirstName = request.FirstName.Trim(),
                LastName = request.LastName.Trim(),
                Phone = request.Phone?.Trim(),
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                Role = "User", // Default role
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                IsActive = true
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            var token = GenerateJwtToken(user);
            
            // Return user without password hash
            var userResponse = new UserResponse
            {
                Id = user.Id,
                Email = user.Email,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Role = user.Role,
                Phone = user.Phone,
                IsActive = user.IsActive
            };

            return Ok(new AuthResponse { Token = token, User = userResponse });
        }

        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<ActionResult<AuthResponse>> Login(LoginRequest request)
        {
            // Validate input
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email.ToLower() == request.Email.ToLower());
                
            if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            {
                return Unauthorized(new { message = "Invalid email or password" });
            }

            if (!user.IsActive)
            {
                return Unauthorized(new { message = "Account is deactivated. Please contact support." });
            }

            var token = GenerateJwtToken(user);
            
            // Return user without password hash
            var userResponse = new UserResponse
            {
                Id = user.Id,
                Email = user.Email,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Role = user.Role,
                Phone = user.Phone,
                IsActive = user.IsActive
            };

            return Ok(new AuthResponse { Token = token, User = userResponse });
        }

        [HttpPost("forgot-password")]
        [AllowAnonymous]
        public async Task<IActionResult> ForgotPassword(ForgotPasswordRequest request)
        {
            // Validate input
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            if (!IsValidEmail(request.Email))
            {
                return BadRequest(new { message = "Invalid email format" });
            }

            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email.ToLower() == request.Email.ToLower());
                
            if (user == null)
            {
                // For security, don't reveal if user exists
                return Ok(new { 
                    message = "If an account exists with this email, a reset code has been sent.",
                    success = true 
                });
            }

            if (!user.IsActive)
            {
                return BadRequest(new { message = "Account is deactivated. Please contact support." });
            }

            // Remove any existing reset requests for this email
            var existingResets = await _context.PasswordResets
                .Where(pr => pr.Email.ToLower() == request.Email.ToLower() && !pr.IsUsed)
                .ToListAsync();
                
            _context.PasswordResets.RemoveRange(existingResets);

            // Generate 6-digit code
            var random = new Random();
            var resetCode = random.Next(100000, 999999).ToString();
            
            // Create password reset record
            var passwordReset = new PasswordReset
            {
                Email = request.Email.ToLower().Trim(),
                Token = Guid.NewGuid().ToString(),
                ResetCode = resetCode,
                ExpiresAt = DateTime.UtcNow.AddMinutes(30), // 30-minute expiry
                IsUsed = false,
                CreatedAt = DateTime.UtcNow
            };

            _context.PasswordResets.Add(passwordReset);
            await _context.SaveChangesAsync();

            // In production, you would send an email here
            // For demo purposes, we'll log it
            Console.WriteLine($"Password reset code for {request.Email}: {resetCode}");
            Console.WriteLine($"Reset token: {passwordReset.Token}");
            Console.WriteLine($"Expires at: {passwordReset.ExpiresAt}");

            return Ok(new { 
                message = "Reset code has been sent to your email.",
                success = true,
                token = passwordReset.Token // Include token for verification step
            });
        }

        [HttpPost("verify-reset-code")]
        [AllowAnonymous]
        public async Task<IActionResult> VerifyResetCode(VerifyResetCodeRequest request)
        {
            // Validate input
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            // Find valid reset request
            var resetRequest = await _context.PasswordResets
                .FirstOrDefaultAsync(pr => 
                    pr.Token == request.Token && 
                    pr.ResetCode == request.ResetCode.Trim() && 
                    pr.ExpiresAt > DateTime.UtcNow && 
                    !pr.IsUsed);

            if (resetRequest == null)
            {
                return BadRequest(new { 
                    message = "Invalid or expired reset code. Please request a new one.",
                    success = false 
                });
            }

            // Verify the user still exists and is active
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email.ToLower() == resetRequest.Email.ToLower() && u.IsActive);
                
            if (user == null)
            {
                return BadRequest(new { 
                    message = "User account not found or is inactive.",
                    success = false 
                });
            }

            return Ok(new { 
                message = "Code verified successfully.",
                success = true,
                token = resetRequest.Token 
            });
        }

        [HttpPost("reset-password")]
        [AllowAnonymous]
        public async Task<IActionResult> ResetPassword(ResetPasswordRequest request)
        {
            // Validate input
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            // Find valid reset request
            var resetRequest = await _context.PasswordResets
                .FirstOrDefaultAsync(pr => 
                    pr.Token == request.Token && 
                    pr.ExpiresAt > DateTime.UtcNow && 
                    !pr.IsUsed);

            if (resetRequest == null)
            {
                return BadRequest(new { 
                    message = "Invalid or expired reset request. Please start the process again.",
                    success = false 
                });
            }

            // Verify passwords match
            if (request.NewPassword != request.ConfirmPassword)
            {
                return BadRequest(new { 
                    message = "Passwords do not match.",
                    success = false 
                });
            }

            // Validate password strength
            if (string.IsNullOrWhiteSpace(request.NewPassword) || request.NewPassword.Length < 6)
            {
                return BadRequest(new { 
                    message = "Password must be at least 6 characters long.",
                    success = false 
                });
            }

            // Find user
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email.ToLower() == resetRequest.Email.ToLower());
                
            if (user == null)
            {
                return BadRequest(new { 
                    message = "User account not found.",
                    success = false 
                });
            }

            if (!user.IsActive)
            {
                return BadRequest(new { 
                    message = "Account is deactivated. Please contact support.",
                    success = false 
                });
            }

            // Update password
            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
            user.UpdatedAt = DateTime.UtcNow;

            // Mark reset request as used
            resetRequest.IsUsed = true;

            await _context.SaveChangesAsync();

            // Remove all other reset requests for this email
            var otherResets = await _context.PasswordResets
                .Where(pr => pr.Email.ToLower() == resetRequest.Email.ToLower() && !pr.IsUsed)
                .ToListAsync();
                
            if (otherResets.Any())
            {
                _context.PasswordResets.RemoveRange(otherResets);
                await _context.SaveChangesAsync();
            }

            return Ok(new { 
                message = "Password has been reset successfully. You can now login with your new password.",
                success = true 
            });
        }

        [HttpPost("change-password")]
        [Authorize]
        public async Task<IActionResult> ChangePassword(ChangePasswordRequest request)
        {
            // Validate input
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            // Get user ID from token
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
            {
                return Unauthorized(new { message = "Invalid authentication token." });
            }

            // Find user
            var user = await _context.Users.FindAsync(userId);
            if (user == null)
            {
                return Unauthorized(new { message = "User not found." });
            }

            if (!user.IsActive)
            {
                return Unauthorized(new { message = "Account is deactivated." });
            }

            // Verify current password
            if (!BCrypt.Net.BCrypt.Verify(request.CurrentPassword, user.PasswordHash))
            {
                return BadRequest(new { message = "Current password is incorrect." });
            }

            // Verify passwords match
            if (request.NewPassword != request.ConfirmPassword)
            {
                return BadRequest(new { message = "New passwords do not match." });
            }

            // Validate new password strength
            if (string.IsNullOrWhiteSpace(request.NewPassword) || request.NewPassword.Length < 6)
            {
                return BadRequest(new { message = "New password must be at least 6 characters long." });
            }

            // Check if new password is same as old password
            if (BCrypt.Net.BCrypt.Verify(request.NewPassword, user.PasswordHash))
            {
                return BadRequest(new { message = "New password cannot be the same as your current password." });
            }

            // Update password
            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
            user.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return Ok(new { 
                message = "Password changed successfully.", 
                success = true 
            });
        }

        [HttpGet("profile")]
        [Authorize]
        public async Task<IActionResult> GetProfile()
        {
            // Get user ID from token
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
            {
                return Unauthorized(new { message = "Invalid authentication token." });
            }

            // Find user
            var user = await _context.Users.FindAsync(userId);
            if (user == null)
            {
                return NotFound(new { message = "User not found." });
            }

            // Return user without password hash
            var userResponse = new UserResponse
            {
                Id = user.Id,
                Email = user.Email,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Role = user.Role,
                Phone = user.Phone,
                IsActive = user.IsActive
            };

            return Ok(userResponse);
        }

        [HttpPost("logout")]
        [Authorize]
        public IActionResult Logout()
        {
            // In a stateless JWT system, logout is handled client-side
            // You might want to implement token blacklisting here if needed
            return Ok(new { 
                message = "Logged out successfully.", 
                success = true 
            });
        }

        private string GenerateJwtToken(User user)
        {
            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.Role, user.Role),
                new Claim(ClaimTypes.GivenName, user.FirstName),
                new Claim(ClaimTypes.Surname, user.LastName),
                new Claim("IsActive", user.IsActive.ToString())
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(
                _configuration["Jwt:Key"] ?? "your-super-secret-key-at-least-32-chars-long!"));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _configuration["Jwt:Issuer"] ?? "AnimalFosteringAPI",
                audience: _configuration["Jwt:Audience"] ?? "AnimalFosteringApp",
                claims: claims,
                expires: DateTime.UtcNow.AddDays(7),
                signingCredentials: creds);

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        private bool IsValidEmail(string email)
        {
            if (string.IsNullOrWhiteSpace(email))
                return false;

            try
            {
                // Simple email validation
                var regex = new Regex(@"^[^@\s]+@[^@\s]+\.[^@\s]+$");
                return regex.IsMatch(email);
            }
            catch
            {
                return false;
            }
        }
    }

    // Request and Response DTOs
    public class RegisterRequest
    {
        [Required(ErrorMessage = "Email is required")]
        [EmailAddress(ErrorMessage = "Invalid email format")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "Password is required")]
        [MinLength(6, ErrorMessage = "Password must be at least 6 characters")]
        public string Password { get; set; } = string.Empty;

        [Required(ErrorMessage = "First name is required")]
        public string FirstName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Last name is required")]
        public string LastName { get; set; } = string.Empty;

        public string? Phone { get; set; }
    }

    public class LoginRequest
    {
        [Required(ErrorMessage = "Email is required")]
        [EmailAddress(ErrorMessage = "Invalid email format")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "Password is required")]
        public string Password { get; set; } = string.Empty;
    }

    public class AuthResponse
    {
        public string Token { get; set; } = string.Empty;
        public UserResponse User { get; set; } = null!;
    }

    public class UserResponse
    {
        public int Id { get; set; }
        public string Email { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
        public string? Phone { get; set; }
        public bool IsActive { get; set; }
    }

    public class ForgotPasswordRequest
    {
        [Required(ErrorMessage = "Email is required")]
        [EmailAddress(ErrorMessage = "Invalid email format")]
        public string Email { get; set; } = string.Empty;
    }

    public class VerifyResetCodeRequest
    {
        [Required(ErrorMessage = "Token is required")]
        public string Token { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Reset code is required")]
        [StringLength(6, MinimumLength = 6, ErrorMessage = "Reset code must be 6 digits")]
        [RegularExpression(@"^\d{6}$", ErrorMessage = "Reset code must be 6 digits")]
        public string ResetCode { get; set; } = string.Empty;
    }

    public class ResetPasswordRequest
    {
        [Required(ErrorMessage = "Token is required")]
        public string Token { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "New password is required")]
        [MinLength(6, ErrorMessage = "New password must be at least 6 characters")]
        public string NewPassword { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Confirm password is required")]
        [Compare("NewPassword", ErrorMessage = "Passwords do not match")]
        public string ConfirmPassword { get; set; } = string.Empty;
    }

    public class ChangePasswordRequest
    {
        [Required(ErrorMessage = "Current password is required")]
        public string CurrentPassword { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "New password is required")]
        [MinLength(6, ErrorMessage = "New password must be at least 6 characters")]
        public string NewPassword { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Confirm password is required")]
        [Compare("NewPassword", ErrorMessage = "New passwords do not match")]
        public string ConfirmPassword { get; set; } = string.Empty;
    }
}