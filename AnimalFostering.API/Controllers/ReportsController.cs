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
    public class ReportsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ReportsController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/reports
        [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> GetReports()
        {
            var reports = await _context.ReportDefinitions
                .OrderByDescending(r => r.UpdatedAt)
                .Select(r => new
                {
                    r.Id,
                    r.Name,
                    r.Description,
                    r.Metric,
                    r.FiltersJson,
                    r.CreatedByUserId,
                    r.CreatedAt,
                    r.UpdatedAt
                })
                .ToListAsync();

            return Ok(reports);
        }

        // POST: api/reports
        [HttpPost]
        public async Task<ActionResult<object>> CreateReport([FromBody] CreateReportRequest request)
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value!);

            var report = new ReportDefinition
            {
                Name = request.Name,
                Description = request.Description,
                Metric = request.Metric,
                FiltersJson = request.FiltersJson,
                CreatedByUserId = userId,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _context.ReportDefinitions.Add(report);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetReports), new { id = report.Id }, new
            {
                report.Id,
                report.Name,
                report.Description,
                report.Metric,
                report.FiltersJson,
                report.CreatedByUserId,
                report.CreatedAt,
                report.UpdatedAt
            });
        }

        // PUT: api/reports/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateReport(int id, [FromBody] UpdateReportRequest request)
        {
            var report = await _context.ReportDefinitions.FindAsync(id);
            if (report == null)
            {
                return NotFound(new { message = "Report not found" });
            }

            report.Name = request.Name;
            report.Description = request.Description;
            report.Metric = request.Metric;
            report.FiltersJson = request.FiltersJson;
            report.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/reports/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteReport(int id)
        {
            var report = await _context.ReportDefinitions.FindAsync(id);
            if (report == null)
            {
                return NotFound(new { message = "Report not found" });
            }

            _context.ReportDefinitions.Remove(report);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }

    public class CreateReportRequest
    {
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string Metric { get; set; } = "ApplicationsSummary";
        public string? FiltersJson { get; set; }
    }

    public class UpdateReportRequest
    {
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string Metric { get; set; } = "ApplicationsSummary";
        public string? FiltersJson { get; set; }
    }
}
