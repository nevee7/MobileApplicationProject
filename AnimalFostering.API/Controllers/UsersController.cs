using System.Security.Claims;
using AnimalFostering.API.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Admin")]
public class UsersController : ControllerBase
{
    private readonly AppDbContext _context;

    public UsersController(AppDbContext context)
    {
        _context = context;
    }

    // GET: api/users
    [HttpGet]
    public async Task<ActionResult<IEnumerable<object>>> GetUsers()
    {
        var users = await _context.Users
            .Select(u => new
            {
                u.Id,
                u.Email,
                u.FirstName,
                u.LastName,
                u.Role,
                u.Phone,
                u.Address,
                u.IsActive,
                u.CreatedAt,
                u.UpdatedAt
            })
            .ToListAsync();
        
        return Ok(users);
    }

    // PATCH: api/users/{id}/status
    [HttpPatch("{id}/status")]
    public async Task<IActionResult> UpdateUserStatus(int id, [FromBody] UpdateUserStatusRequest request)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null) 
            return NotFound(new { message = "User not found" });

        // Prevent admin from deactivating themselves
        var currentUserId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value!);
        if (user.Id == currentUserId)
            return BadRequest(new { message = "Cannot deactivate your own account" });

        user.IsActive = request.IsActive;
        user.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();
        return NoContent();
    }

    // PATCH: api/users/{id}/role
    [HttpPatch("{id}/role")]
    public async Task<IActionResult> UpdateUserRole(int id, [FromBody] UpdateRoleRequest request)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null) 
            return NotFound(new { message = "User not found" });

        var currentUserId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value!);
        if (user.Id == currentUserId)
            return BadRequest(new { message = "Cannot change your own role" });

        user.Role = request.Role;
        user.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();
        return NoContent();
    }
}

public class UpdateUserStatusRequest
{
    public bool IsActive { get; set; }
}

public class UpdateRoleRequest
{
    public string Role { get; set; } = string.Empty;
}