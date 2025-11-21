// Controllers/AnimalsController.cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AnimalFostering.API.Data;
using AnimalFostering.API.Models;

namespace AnimalFostering.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AnimalsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AnimalsController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/animals with search and filters
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Animal>>> GetAnimals(
            [FromQuery] string? search,
            [FromQuery] string? species,
            [FromQuery] string? status,
            [FromQuery] string? shelter)
        {
            var query = _context.Animals.AsQueryable();

            // Search by name, breed, or description
            if (!string.IsNullOrEmpty(search))
            {
                query = query.Where(a => 
                    a.Name.Contains(search) || 
                    a.Breed.Contains(search) || 
                    a.Description.Contains(search));
            }

            // Filter by species
            if (!string.IsNullOrEmpty(species))
            {
                query = query.Where(a => a.Species == species);
            }

            // Filter by status
            if (!string.IsNullOrEmpty(status))
            {
                query = query.Where(a => a.Status.ToLower() == status.ToLower());
            }

            // Filter by shelter (you'll need to implement shelter logic)
            if (!string.IsNullOrEmpty(shelter) && int.TryParse(shelter, out int shelterId))
            {
                query = query.Where(a => a.ShelterId == shelterId);
            }

            var animals = await query.ToListAsync();
            return Ok(animals);
        }

        // GET: api/animals/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Animal>> GetAnimal(int id)
        {
            var animal = await _context.Animals.FindAsync(id);

            if (animal == null)
            {
                return NotFound(new { message = "Animal not found" });
            }

            return animal;
        }

        // POST: api/animals
        [HttpPost]
        public async Task<ActionResult<Animal>> PostAnimal(Animal animal)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            // Set timestamps
            animal.CreatedAt = DateTime.UtcNow;
            animal.UpdatedAt = DateTime.UtcNow;

            _context.Animals.Add(animal);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetAnimal), new { id = animal.Id }, animal);
        }

        // PUT: api/animals/5
        [HttpPut("{id}")]
        public async Task<IActionResult> PutAnimal(int id, Animal animal)
        {
            if (id != animal.Id)
            {
                return BadRequest();
            }

            var existingAnimal = await _context.Animals.FindAsync(id);
            if (existingAnimal == null)
            {
                return NotFound();
            }

            // Update properties
            existingAnimal.Name = animal.Name;
            existingAnimal.Species = animal.Species;
            existingAnimal.Breed = animal.Breed;
            existingAnimal.Age = animal.Age;
            existingAnimal.Gender = animal.Gender;
            existingAnimal.Size = animal.Size;
            existingAnimal.Description = animal.Description;
            existingAnimal.MedicalNotes = animal.MedicalNotes;
            existingAnimal.Status = animal.Status;
            existingAnimal.ImageUrl = animal.ImageUrl;
            existingAnimal.ShelterId = animal.ShelterId;
            existingAnimal.UpdatedAt = DateTime.UtcNow;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!AnimalExists(id))
                {
                    return NotFound();
                }
                throw;
            }

            return NoContent();
        }

        // DELETE: api/animals/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteAnimal(int id)
        {
            var animal = await _context.Animals.FindAsync(id);
            if (animal == null)
            {
                return NotFound();
            }

            _context.Animals.Remove(animal);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool AnimalExists(int id)
        {
            return _context.Animals.Any(e => e.Id == id);
        }
    }
}