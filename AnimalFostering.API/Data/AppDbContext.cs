using Microsoft.EntityFrameworkCore;
using AnimalFostering.API.Models;

namespace AnimalFostering.API.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<Animal> Animals { get; set; }
        public DbSet<Shelter> Shelters { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<PasswordReset> PasswordResets { get; set; } // Add this line

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Animal configuration
            modelBuilder.Entity<Animal>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Name).IsRequired();
                entity.Property(e => e.Species).IsRequired();
                entity.Property(e => e.Breed).IsRequired();
                entity.Property(e => e.Description).IsRequired();
            });

            // Shelter configuration
            modelBuilder.Entity<Shelter>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Name).IsRequired();
                entity.Property(e => e.Address).IsRequired();
            });

            // User configuration
            modelBuilder.Entity<User>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Email).IsRequired();
                entity.Property(e => e.PasswordHash).IsRequired();
                entity.Property(e => e.FirstName).IsRequired();
                entity.Property(e => e.LastName).IsRequired();
                entity.HasIndex(e => e.Email).IsUnique(); // Ensure email is unique
            });

            // PasswordReset configuration
            modelBuilder.Entity<PasswordReset>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Email).IsRequired();
                entity.Property(e => e.Token).IsRequired();
                entity.Property(e => e.ResetCode).IsRequired();
                
                // Add index on Token and Email for faster lookups
                entity.HasIndex(e => e.Token);
                entity.HasIndex(e => e.Email);
                entity.HasIndex(e => new { e.Token, e.ResetCode, e.IsUsed });
                
                // Set default values
                entity.Property(e => e.IsUsed).HasDefaultValue(false);
                entity.Property(e => e.CreatedAt).HasDefaultValueSql("CURRENT_TIMESTAMP");
            });
        }
    }
}