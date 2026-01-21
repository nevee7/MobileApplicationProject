// Controllers/SheltersController.cs
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AnimalFostering.API.Data;
using AnimalFostering.API.Models;

namespace AnimalFostering.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class SheltersController : ControllerBase
    {
        private readonly AppDbContext _context;

        public SheltersController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/shelters
        [HttpGet]
        [AllowAnonymous]
        public async Task<ActionResult<IEnumerable<object>>> GetShelters([FromQuery] bool includeInactive = false)
        {
            var isAuthenticated = User.Identity?.IsAuthenticated == true;
            var isAdmin = false;

            if (isAuthenticated)
            {
                var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value!);
                var user = await _context.Users.FindAsync(userId);
                isAdmin = user?.Role == "Admin";
            }

            var query = _context.Shelters.AsQueryable();
            if (!isAdmin || !includeInactive)
            {
                query = query.Where(s => s.IsActive);
            }

            var shelters = await query
                .Select(s => new
                {
                    s.Id,
                    s.Name,
                    s.Address,
                    s.City,
                    s.Phone,
                    s.Email,
                    s.Latitude,
                    s.Longitude,
                    s.Description,
                    s.IsActive
                })
                .ToListAsync();

            return Ok(shelters);
        }

        // GET: api/shelters/{id}/details
        [HttpGet("{id}/details")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<object>> GetShelterDetails(int id)
        {
            var shelter = await _context.Shelters.FindAsync(id);
            if (shelter == null)
            {
                return NotFound(new { message = "Shelter not found" });
            }

            var animals = await _context.Animals
                .Where(a => a.ShelterId == id)
                .Select(a => new
                {
                    a.Id,
                    a.Name,
                    a.Species,
                    a.Breed,
                    a.Age,
                    a.Gender,
                    a.Status,
                    a.ImageUrl
                })
                .ToListAsync();

            var stats = new
            {
                total = animals.Count,
                available = animals.Count(a => a.Status.ToLower() == "available"),
                adopted = animals.Count(a => a.Status.ToLower() == "adopted"),
                fostered = animals.Count(a => a.Status.ToLower() == "fostered"),
                pending = animals.Count(a => a.Status.ToLower() == "pending"),
            };

            return Ok(new
            {
                shelter.Id,
                shelter.Name,
                shelter.Address,
                shelter.City,
                shelter.Phone,
                shelter.Email,
                shelter.Latitude,
                shelter.Longitude,
                shelter.Description,
                shelter.IsActive,
                Animals = animals,
                Stats = stats
            });
        }

        // POST: api/shelters
        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<object>> CreateShelter([FromBody] ShelterRequest request)
        {
            var shelter = new Shelter
            {
                Name = request.Name,
                Address = request.Address,
                City = request.City,
                Phone = request.Phone,
                Email = request.Email,
                Latitude = request.Latitude,
                Longitude = request.Longitude,
                Description = request.Description,
                IsActive = request.IsActive,
                Source = "Local",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _context.Shelters.Add(shelter);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetShelters), new { id = shelter.Id }, new
            {
                shelter.Id,
                shelter.Name,
                shelter.Address,
                shelter.City,
                shelter.Phone,
                shelter.Email,
                shelter.Latitude,
                shelter.Longitude,
                shelter.Description,
                shelter.IsActive
            });
        }

        // PUT: api/shelters/{id}
        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> UpdateShelter(int id, [FromBody] ShelterRequest request)
        {
            var shelter = await _context.Shelters.FindAsync(id);
            if (shelter == null)
            {
                return NotFound(new { message = "Shelter not found" });
            }

            shelter.Name = request.Name;
            shelter.Address = request.Address;
            shelter.City = request.City;
            shelter.Phone = request.Phone;
            shelter.Email = request.Email;
            shelter.Latitude = request.Latitude;
            shelter.Longitude = request.Longitude;
            shelter.Description = request.Description;
            shelter.IsActive = request.IsActive;
            shelter.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return NoContent();
        }

        // PATCH: api/shelters/{id}/status
        [HttpPatch("{id}/status")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> UpdateShelterStatus(int id, [FromBody] UpdateShelterStatusRequest request)
        {
            var shelter = await _context.Shelters.FindAsync(id);
            if (shelter == null)
            {
                return NotFound(new { message = "Shelter not found" });
            }

            shelter.IsActive = request.IsActive;
            shelter.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // DELETE: api/shelters/{id} (soft delete)
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> DeleteShelter(int id)
        {
            var shelter = await _context.Shelters.FindAsync(id);
            if (shelter == null)
            {
                return NotFound(new { message = "Shelter not found" });
            }

            shelter.IsActive = false;
            shelter.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }

    public class ShelterRequest
    {
        public string Name { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string? City { get; set; }
        public string? Phone { get; set; }
        public string? Email { get; set; }
        public double? Latitude { get; set; }
        public double? Longitude { get; set; }
        public string? Description { get; set; }
        public bool IsActive { get; set; } = true;
    }

    public class UpdateShelterStatusRequest
    {
        public bool IsActive { get; set; }
    }
}
