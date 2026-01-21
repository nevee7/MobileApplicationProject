using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.EntityFrameworkCore;
using System.Text;
using AnimalFostering.API.Data;
using AnimalFostering.API.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddHttpClient();

// Add DbContext with PostgreSQL
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") 
    ?? "Host=localhost;Port=5432;Database=AnimalFostering;Username=postgres;Password=password;";

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(connectionString));

// Configure JWT Authentication
var jwtKey = builder.Configuration["Jwt:Key"] 
    ?? "your-super-secret-key-at-least-32-chars-long!";
var jwtIssuer = builder.Configuration["Jwt:Issuer"] 
    ?? "AnimalFosteringAPI";
var jwtAudience = builder.Configuration["Jwt:Audience"] 
    ?? "AnimalFosteringApp";

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtIssuer,
            ValidAudience = jwtAudience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
        };
    });

builder.Services.AddAuthorization();

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutterApp",
        policy =>
        {
            policy.WithOrigins("http://localhost", "http://10.0.2.2:5000", "http://localhost:5000")
                  .AllowAnyHeader()
                  .AllowAnyMethod();
        });
});

var app = builder.Build();

// Initialize database
try
{
    using (var scope = app.Services.CreateScope())
    {
        var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        context.Database.Migrate();
        
        // Seed initial data if needed
        if (!context.Users.Any())
        {
            // Create default admin user
            var adminUser = new User
            {
                Email = "admin@pawsconnect.com",
                FirstName = "Admin",
                LastName = "User",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("admin123"),
                Role = "Admin",
                IsActive = true,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            context.Users.Add(adminUser);
            context.SaveChanges();
        }

        SeedData.Initialize(context);
    }
    Console.WriteLine("Database initialized successfully.");
}
catch (Exception ex)
{
    Console.WriteLine($"An error occurred while initializing the database: {ex.Message}");
}

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowFlutterApp");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Urls.Add("http://0.0.0.0:5000");
app.Run();
