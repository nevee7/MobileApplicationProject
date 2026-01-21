using System.Security.Claims;
using AnimalFostering.API.Data;
using AnimalFostering.API.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AnimalFostering.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ApplicationsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ApplicationsController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/applications
        [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> GetApplications()
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value!);
            var user = await _context.Users.FindAsync(userId);
            
            if (user?.Role == "Admin")
            {
                var applications = await _context.AdoptionApplications
                    .Include(a => a.User)
                    .Include(a => a.Animal)
                    .Select(a => new
                    {
                        a.Id,
                        a.UserId,
                        a.AnimalId,
                        a.Status,
                        a.Message,
                        a.AdminNotes,
                        a.ApplicationDate,
                        a.ReviewedDate,
                        a.ReviewedByAdminId,
                        User = new
                        {
                            a.User.Id,
                            a.User.Email,
                            a.User.FirstName,
                            a.User.LastName,
                            a.User.Role,
                            a.User.Phone,
                            a.User.IsActive
                        },
                        Animal = a.Animal != null ? new
                        {
                            a.Animal.Id,
                            a.Animal.Name,
                            a.Animal.Species,
                            a.Animal.Breed,
                            a.Animal.Age,
                            a.Animal.Gender,
                            a.Animal.Status,
                            a.Animal.ImageUrl
                        } : null
                    })
                    .ToListAsync();
                
                return Ok(applications);
            }
            else
            {
                var applications = await _context.AdoptionApplications
                    .Include(a => a.User)
                    .Include(a => a.Animal)
                    .Where(a => a.UserId == userId)
                    .Select(a => new
                    {
                        a.Id,
                        a.UserId,
                        a.AnimalId,
                        a.Status,
                        a.Message,
                        a.AdminNotes,
                        a.ApplicationDate,
                        a.ReviewedDate,
                        a.ReviewedByAdminId,
                        User = new
                        {
                            a.User.Id,
                            a.User.Email,
                            a.User.FirstName,
                            a.User.LastName,
                            a.User.Role,
                            a.User.Phone,
                            a.User.IsActive
                        },
                        Animal = a.Animal != null ? new
                        {
                            a.Animal.Id,
                            a.Animal.Name,
                            a.Animal.Species,
                            a.Animal.Breed,
                            a.Animal.Age,
                            a.Animal.Gender,
                            a.Animal.Status,
                            a.Animal.ImageUrl
                        } : null
                    })
                    .ToListAsync();
                
                return Ok(applications);
            }
        }

        // GET: api/users/{userId}/applications
        [HttpGet("~/api/users/{userId}/applications")]
        public async Task<ActionResult<IEnumerable<object>>> GetUserApplications(int userId)
        {
            var currentUserId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value!);
            var currentUser = await _context.Users.FindAsync(currentUserId);
            
            // Only allow admin or the user themselves
            if (currentUser?.Role != "Admin" && currentUserId != userId)
                return Forbid();

            var applications = await _context.AdoptionApplications
                .Include(a => a.User)
                .Include(a => a.Animal)
                .Where(a => a.UserId == userId)
                .Select(a => new
                {
                    a.Id,
                    a.UserId,
                    a.AnimalId,
                    a.Status,
                    a.Message,
                    a.AdminNotes,
                    a.ApplicationDate,
                    a.ReviewedDate,
                    a.ReviewedByAdminId,
                    User = new
                    {
                        a.User.Id,
                        a.User.Email,
                        a.User.FirstName,
                        a.User.LastName,
                        a.User.Role,
                        a.User.Phone,
                        a.User.IsActive
                    },
                    Animal = a.Animal != null ? new
                    {
                        a.Animal.Id,
                        a.Animal.Name,
                        a.Animal.Species,
                        a.Animal.Breed,
                        a.Animal.Age,
                        a.Animal.Gender,
                        a.Animal.Status,
                        a.Animal.ImageUrl
                    } : null
                })
                .ToListAsync();
            
            return Ok(applications);
        }

        // POST: api/applications
        [HttpPost]
        public async Task<ActionResult<object>> CreateApplication(CreateApplicationRequest request)
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value!);
            
            // Check if animal exists
            var animal = await _context.Animals.FindAsync(request.AnimalId);
            if (animal == null) 
                return NotFound(new { message = "Animal not found" });

            // Check if user already has pending application for this animal
            var existingApplication = await _context.AdoptionApplications
                .FirstOrDefaultAsync(a => a.UserId == userId && a.AnimalId == request.AnimalId && a.Status == "Pending");
            
            if (existingApplication != null)
                return BadRequest(new { message = "You already have a pending application for this animal" });

            var application = new AdoptionApplication
            {
                UserId = userId,
                AnimalId = request.AnimalId,
                Status = "Pending",
                Message = request.Message,
                AdminNotes = null,
                ApplicationDate = DateTime.UtcNow,
                ReviewedDate = null,
                ReviewedByAdminId = null
            };

            _context.AdoptionApplications.Add(application);
            await _context.SaveChangesAsync();

            // Return the created application with user and animal info
            var user = await _context.Users.FindAsync(userId);
            var adminIds = await _context.Users
                .Where(u => u.Role == "Admin" && u.IsActive)
                .Select(u => u.Id)
                .ToListAsync();

            foreach (var adminId in adminIds)
            {
                _context.Notifications.Add(new Notification
                {
                    UserId = adminId,
                    Title = "New Adoption Application",
                    Message = $"{user?.FirstName} {user?.LastName} applied to adopt {animal.Name}.",
                    Type = "Info",
                    RelatedEntityType = "Application",
                    RelatedEntityId = application.Id,
                    IsRead = false,
                    CreatedAt = DateTime.UtcNow
                });
            }

            await _context.SaveChangesAsync();

            var createdApplication = new
            {
                application.Id,
                application.UserId,
                application.AnimalId,
                application.Status,
                application.Message,
                application.AdminNotes,
                application.ApplicationDate,
                application.ReviewedDate,
                application.ReviewedByAdminId,
                User = user != null ? new
                {
                    user.Id,
                    user.Email,
                    user.FirstName,
                    user.LastName,
                    user.Role,
                    user.Phone,
                    user.IsActive
                } : null,
                Animal = animal != null ? new
                {
                    animal.Id,
                    animal.Name,
                    animal.Species,
                    animal.Breed,
                    animal.Age,
                    animal.Gender,
                    animal.Status,
                    animal.ImageUrl
                } : null
            };

            return CreatedAtAction(nameof(GetApplications), new { id = application.Id }, createdApplication);
        }

        // PATCH: api/applications/{id}/status
        [HttpPatch("{id}/status")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> UpdateApplicationStatus(int id, [FromBody] UpdateApplicationStatusRequest request)
        {
            var application = await _context.AdoptionApplications
                .Include(a => a.Animal)
                .Include(a => a.User)
                .FirstOrDefaultAsync(a => a.Id == id);
            if (application == null) 
                return NotFound(new { message = "Application not found" });

            var adminId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value!);

            application.Status = request.Status;
            application.AdminNotes = request.AdminNotes;
            application.ReviewedDate = DateTime.UtcNow;
            application.ReviewedByAdminId = adminId;

            if (application.Animal != null &&
                string.Equals(request.Status, "Approved", StringComparison.OrdinalIgnoreCase))
            {
                application.Animal.Status = "adopted";
            }

            await _context.SaveChangesAsync();

            _context.Notifications.Add(new Notification
            {
                UserId = application.UserId,
                Title = $"Application {application.Status}",
                Message = $"Your application for {application.Animal?.Name ?? "the animal"} was {application.Status.ToLowerInvariant()}.",
                Type = application.Status == "Approved" ? "Success" : "Warning",
                RelatedEntityType = "Application",
                RelatedEntityId = application.Id,
                IsRead = false,
                CreatedAt = DateTime.UtcNow
            });

            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/applications/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteApplication(int id)
        {
            var application = await _context.AdoptionApplications.FindAsync(id);
            if (application == null) 
                return NotFound(new { message = "Application not found" });

            // Only allow admin or the owner to delete
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value!);
            var user = await _context.Users.FindAsync(userId);
            
            if (user?.Role != "Admin" && application.UserId != userId)
                return Forbid();

            _context.AdoptionApplications.Remove(application);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }

    public class CreateApplicationRequest
    {
        public int AnimalId { get; set; }
        public string? Message { get; set; }
    }

    public class UpdateApplicationStatusRequest
    {
        public string Status { get; set; } = string.Empty;
        public string? AdminNotes { get; set; }
    }
}
