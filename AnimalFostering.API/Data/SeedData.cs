// Data/SeedData.cs
using AnimalFostering.API.Models;
using Microsoft.EntityFrameworkCore;

namespace AnimalFostering.API.Data
{
    public static class SeedData
    {
        public static void Initialize(AppDbContext context)
        {
            context.Database.Migrate();

            if (!context.Shelters.Any())
            {
                context.Shelters.AddRange(
                    new Shelter
                    {
                        Name = "Happy Paws Shelter",
                        Address = "123 Main Street",
                        City = "Timișoara",
                        Phone = "+40 123 456 789",
                        Email = "contact@happypaws.ro",
                        Latitude = 45.7489,
                        Longitude = 21.2087,
                        Description = "Dedicated to finding loving homes for pets in Timișoara"
                    },
                    new Shelter
                    {
                        Name = "Animal Rescue Center",
                        Address = "456 Oak Avenue",
                        City = "Timișoara",
                        Phone = "+40 234 567 890",
                        Email = "info@animalrescue.ro",
                        Latitude = 45.7557,
                        Longitude = 21.2295,
                        Description = "Providing shelter and care for abandoned animals"
                    }
                );
                context.SaveChanges();
            }

            if (!context.Animals.Any())
            {
                context.Animals.AddRange(
                    new Animal
                    {
                        Name = "Luna",
                        Species = "Dog",
                        Breed = "Golden Retriever",
                        Age = 2,
                        Gender = "Female",
                        Size = "Large",
                        Description = "Luna is a friendly and energetic golden retriever who loves to play and cuddle.",
                        MedicalNotes = "Up to date on all vaccinations",
                        Status = "available",
                        ImageUrl = "https://images.unsplash.com/photo-1552053831-71594a27632d?w=400",
                        ShelterId = 1
                    },
                    new Animal
                    {
                        Name = "Whiskers",
                        Species = "Cat",
                        Breed = "Siamese",
                        Age = 3,
                        Gender = "Male",
                        Size = "Medium",
                        Description = "Whiskers is a calm and affectionate cat who enjoys quiet environments.",
                        MedicalNotes = "Neutered and vaccinated",
                        Status = "available",
                        ImageUrl = "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400",
                        ShelterId = 1
                    }
                );
                context.SaveChanges();
            }
        }
    }
}