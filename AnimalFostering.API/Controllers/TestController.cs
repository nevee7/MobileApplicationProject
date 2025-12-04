using Microsoft.AspNetCore.Mvc;

namespace AnimalFostering.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TestController : ControllerBase
    {
        [HttpGet]
        public IActionResult Get()
        {
            return Ok(new { message = "Backend is working!", timestamp = DateTime.UtcNow });
        }

        [HttpGet("auth-test")]
        public IActionResult AuthTest()
        {
            return Ok(new { message = "Authentication test successful!" });
        }
    }
}