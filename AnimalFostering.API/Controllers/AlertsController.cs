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
    [Authorize(Roles = "Admin")]
    public class AlertsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AlertsController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/alerts
        [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> GetAlerts()
        {
            var alerts = await _context.AlertRules
                .OrderByDescending(a => a.UpdatedAt)
                .Select(a => new
                {
                    a.Id,
                    a.Name,
                    a.Metric,
                    a.Comparison,
                    a.Threshold,
                    a.IsActive,
                    a.CreatedByUserId,
                    a.CreatedAt,
                    a.UpdatedAt
                })
                .ToListAsync();

            return Ok(alerts);
        }

        // POST: api/alerts
        [HttpPost]
        public async Task<ActionResult<object>> CreateAlert([FromBody] CreateAlertRequest request)
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value!);

            var alert = new AlertRule
            {
                Name = request.Name,
                Metric = request.Metric,
                Comparison = request.Comparison,
                Threshold = request.Threshold,
                IsActive = request.IsActive,
                CreatedByUserId = userId,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _context.AlertRules.Add(alert);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetAlerts), new { id = alert.Id }, new
            {
                alert.Id,
                alert.Name,
                alert.Metric,
                alert.Comparison,
                alert.Threshold,
                alert.IsActive,
                alert.CreatedByUserId,
                alert.CreatedAt,
                alert.UpdatedAt
            });
        }

        // PUT: api/alerts/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateAlert(int id, [FromBody] UpdateAlertRequest request)
        {
            var alert = await _context.AlertRules.FindAsync(id);
            if (alert == null)
            {
                return NotFound(new { message = "Alert not found" });
            }

            alert.Name = request.Name;
            alert.Metric = request.Metric;
            alert.Comparison = request.Comparison;
            alert.Threshold = request.Threshold;
            alert.IsActive = request.IsActive;
            alert.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/alerts/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteAlert(int id)
        {
            var alert = await _context.AlertRules.FindAsync(id);
            if (alert == null)
            {
                return NotFound(new { message = "Alert not found" });
            }

            _context.AlertRules.Remove(alert);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }

    public class CreateAlertRequest
    {
        public string Name { get; set; } = string.Empty;
        public string Metric { get; set; } = "PendingApplications";
        public string Comparison { get; set; } = "GreaterThan";
        public int Threshold { get; set; }
        public bool IsActive { get; set; } = true;
    }

    public class UpdateAlertRequest
    {
        public string Name { get; set; } = string.Empty;
        public string Metric { get; set; } = "PendingApplications";
        public string Comparison { get; set; } = "GreaterThan";
        public int Threshold { get; set; }
        public bool IsActive { get; set; } = true;
    }
}
