// Data/AppDbContext.cs
using Microsoft.EntityFrameworkCore;
using AnimalFostering.API.Models;

namespace AnimalFostering.API.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        // Use proper DbSet<T> types
        public DbSet<Animal> Animals { get; set; }
        public DbSet<Shelter> Shelters { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<PasswordReset> PasswordResets { get; set; }
        public DbSet<AdoptionApplication> AdoptionApplications { get; set; }
        public DbSet<ChatMessage> ChatMessages { get; set; }

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
                entity.HasIndex(e => e.Email).IsUnique();
            });

            // PasswordReset configuration
            modelBuilder.Entity<PasswordReset>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Email).IsRequired();
                entity.Property(e => e.Token).IsRequired();
                entity.Property(e => e.ResetCode).IsRequired();
                
                entity.HasIndex(e => e.Token);
                entity.HasIndex(e => e.Email);
                entity.HasIndex(e => new { e.Token, e.ResetCode, e.IsUsed });
                
                entity.Property(e => e.IsUsed).HasDefaultValue(false);
                entity.Property(e => e.CreatedAt).HasDefaultValueSql("CURRENT_TIMESTAMP");
            });

            // AdoptionApplication configuration
            modelBuilder.Entity<AdoptionApplication>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Status).IsRequired();
                entity.Property(e => e.ApplicationDate).IsRequired();
                
                // Relationships
                entity.HasOne(e => e.User)
                    .WithMany()
                    .HasForeignKey(e => e.UserId)
                    .OnDelete(DeleteBehavior.Restrict);
                    
                entity.HasOne(e => e.Animal)
                    .WithMany()
                    .HasForeignKey(e => e.AnimalId)
                    .OnDelete(DeleteBehavior.Restrict);
                    
                entity.HasOne(e => e.ReviewedByAdmin)
                    .WithMany()
                    .HasForeignKey(e => e.ReviewedByAdminId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            // ChatMessage configuration
            modelBuilder.Entity<ChatMessage>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.MessageType).IsRequired();
                entity.Property(e => e.Content).IsRequired();
                entity.Property(e => e.SentAt).IsRequired();
                
                // Relationships
                entity.HasOne(e => e.Sender)
                    .WithMany()
                    .HasForeignKey(e => e.SenderId)
                    .OnDelete(DeleteBehavior.Restrict);
                    
                entity.HasOne(e => e.Receiver)
                    .WithMany()
                    .HasForeignKey(e => e.ReceiverId)
                    .OnDelete(DeleteBehavior.Restrict);
            });
        }
    }
}