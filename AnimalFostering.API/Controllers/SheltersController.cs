// Controllers/SheltersController.cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AnimalFostering.API.Data;
using AnimalFostering.API.Models;

namespace AnimalFostering.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SheltersController : ControllerBase
    {
        private readonly AppDbContext _context;

        public SheltersController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/shelters
        [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> GetShelters()
        {
            var shelters = await _context.Shelters
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
                    s.Description
                })
                .ToListAsync();

            return Ok(shelters);
        }
    }
}