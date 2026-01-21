using System.Security.Claims;
using AnimalFostering.API.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AnimalFostering.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class NotificationsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public NotificationsController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/notifications
        [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> GetNotifications()
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value!);

            var notifications = await _context.Notifications
                .Where(n => n.UserId == userId)
                .OrderByDescending(n => n.CreatedAt)
                .Select(n => new
                {
                    n.Id,
                    n.Title,
                    n.Message,
                    n.Type,
                    n.IsRead,
                    n.CreatedAt,
                    n.RelatedEntityType,
                    n.RelatedEntityId
                })
                .ToListAsync();

            return Ok(notifications);
        }

        // PATCH: api/notifications/{id}/read
        [HttpPatch("{id}/read")]
        public async Task<IActionResult> MarkAsRead(int id)
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value!);
            var notification = await _context.Notifications.FirstOrDefaultAsync(n => n.Id == id && n.UserId == userId);
            if (notification == null)
            {
                return NotFound(new { message = "Notification not found" });
            }

            notification.IsRead = true;
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // PATCH: api/notifications/read-all
        [HttpPatch("read-all")]
        public async Task<IActionResult> MarkAllAsRead()
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value!);
            var notifications = await _context.Notifications
                .Where(n => n.UserId == userId && !n.IsRead)
                .ToListAsync();

            foreach (var notification in notifications)
            {
                notification.IsRead = true;
            }

            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/notifications/clear
        [HttpDelete("clear")]
        public async Task<IActionResult> ClearAll()
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value!);
            var notifications = await _context.Notifications
                .Where(n => n.UserId == userId)
                .ToListAsync();

            _context.Notifications.RemoveRange(notifications);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
