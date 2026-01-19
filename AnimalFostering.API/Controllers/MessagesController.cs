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
    public class MessagesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public MessagesController(AppDbContext context)
        {
            _context = context;
        }

        // POST: api/messages
        [HttpPost]
        public async Task<ActionResult<object>> SendMessage([FromBody] SendMessageRequest request)
        {
            var senderId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value!);
            
            // Validate receiver if specified
            if (request.ReceiverId.HasValue)
            {
                var receiver = await _context.Users.FindAsync(request.ReceiverId.Value);
                if (receiver == null)
                    return BadRequest(new { message = "Receiver not found" });
            }

            var message = new ChatMessage
            {
                SenderId = senderId,
                ReceiverId = request.ReceiverId,
                MessageType = request.MessageType,
                Content = request.Message,
                IsRead = false,
                SentAt = DateTime.UtcNow
            };

            _context.ChatMessages.Add(message);
            await _context.SaveChangesAsync();

            return Ok(new 
            { 
                message = "Message sent successfully",
                messageId = message.Id 
            });
        }

        // GET: api/messages
        [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> GetMessages()
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value!);
            var user = await _context.Users.FindAsync(userId);
            
            if (user?.Role == "Admin")
            {
                // Admin gets all messages
                var messages = await _context.ChatMessages
                    .Include(m => m.Sender)
                    .Include(m => m.Receiver)
                    .OrderByDescending(m => m.SentAt)
                    .Take(50)
                    .Select(m => new
                    {
                        m.Id,
                        m.SenderId,
                        m.ReceiverId,
                        m.MessageType,
                        m.Content,
                        m.IsRead,
                        m.SentAt,
                        Sender = new
                        {
                            m.Sender.Id,
                            m.Sender.FirstName,
                            m.Sender.LastName,
                            m.Sender.Email,
                            m.Sender.Role
                        },
                        Receiver = m.Receiver != null ? new
                        {
                            m.Receiver.Id,
                            m.Receiver.FirstName,
                            m.Receiver.LastName,
                            m.Receiver.Email,
                            m.Receiver.Role
                        } : null
                    })
                    .ToListAsync();
                
                return Ok(messages);
            }
            else
            {
                // Users get only their messages with admins
                var messages = await _context.ChatMessages
                    .Include(m => m.Sender)
                    .Include(m => m.Receiver)
                    .Where(m => m.SenderId == userId || m.ReceiverId == userId || 
                               (m.ReceiverId == null && m.Sender.Role == "Admin"))
                    .OrderByDescending(m => m.SentAt)
                    .Take(50)
                    .Select(m => new
                    {
                        m.Id,
                        m.SenderId,
                        m.ReceiverId,
                        m.MessageType,
                        m.Content,
                        m.IsRead,
                        m.SentAt,
                        Sender = new
                        {
                            m.Sender.Id,
                            m.Sender.FirstName,
                            m.Sender.LastName,
                            m.Sender.Email,
                            m.Sender.Role
                        },
                        Receiver = m.Receiver != null ? new
                        {
                            m.Receiver.Id,
                            m.Receiver.FirstName,
                            m.Receiver.LastName,
                            m.Receiver.Email,
                            m.Receiver.Role
                        } : null
                    })
                    .ToListAsync();
                
                return Ok(messages);
            }
        }
    }

    public class SendMessageRequest
    {
        public int? ReceiverId { get; set; }
        public string Message { get; set; } = string.Empty;
        public string MessageType { get; set; } = "Text";
    }
}