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

            var sheltersToSeed = new List<Shelter>
            {
                new Shelter
                {
                    Name = "Animal Protection Association Timisoara",
                    Address = "Bega Street 1",
                    City = "Timisoara",
                    Phone = "+40 256 494 320",
                    Email = "contact@apa-tm.ro",
                    Latitude = 45.752821,
                    Longitude = 21.228017,
                    Description = "Main animal protection association in Timisoara",
                    IsActive = true
                },
                new Shelter
                {
                    Name = "Salvami Animal Rescue",
                    Address = "Coriolan Brediceanu Street 10",
                    City = "Timisoara",
                    Phone = "+40 256 222 222",
                    Email = "hello@salvami.ro",
                    Latitude = 45.749275,
                    Longitude = 21.229570,
                    Description = "Animal rescue and protection organization",
                    IsActive = true
                },
                new Shelter
                {
                    Name = "Doctor Vet Clinic",
                    Address = "Liviu Rebreanu Boulevard 48",
                    City = "Timisoara",
                    Phone = "+40 256 293 939",
                    Email = "contact@doctorvet.ro",
                    Latitude = 45.769898,
                    Longitude = 21.217364,
                    Description = "Veterinary clinic with emergency services",
                    IsActive = true
                },
                new Shelter
                {
                    Name = "Animed Veterinary Center",
                    Address = "Vasile Alecsandri Street 2",
                    City = "Timisoara",
                    Phone = "+40 256 200 600",
                    Email = "office@animed.ro",
                    Latitude = 45.751511,
                    Longitude = 21.225671,
                    Description = "Modern veterinary clinic",
                    IsActive = true
                }
            };

            var existingShelterNames = new HashSet<string>(
                context.Shelters.Select(s => s.Name).ToList(),
                StringComparer.OrdinalIgnoreCase
            );

            var sheltersToAdd = sheltersToSeed.Where(s => !existingShelterNames.Contains(s.Name)).ToList();
            if (sheltersToAdd.Any())
            {
                context.Shelters.AddRange(sheltersToAdd);
                context.SaveChanges();
            }

            var sheltersByName = context.Shelters
                .ToDictionary(s => s.Name, s => s.Id, StringComparer.OrdinalIgnoreCase);

            int shelter1 = sheltersByName["Animal Protection Association Timisoara"];
            int shelter2 = sheltersByName["Salvami Animal Rescue"];
            int shelter3 = sheltersByName["Doctor Vet Clinic"];
            int shelter4 = sheltersByName["Animed Veterinary Center"];

            var animalsToSeed = new List<Animal>
            {
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
                    ImageUrl = "https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=400",
                    ShelterId = shelter1
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
                    ShelterId = shelter2
                },
                new Animal
                {
                    Name = "Buddy",
                    Species = "Dog",
                    Breed = "Labrador Retriever",
                    Age = 4,
                    Gender = "Male",
                    Size = "Large",
                    Description = "Buddy is a loyal lab who loves long walks and belly rubs.",
                    MedicalNotes = "Vaccinated and microchipped",
                    Status = "available",
                    ImageUrl = "https://images.unsplash.com/photo-1507146426996-ef05306b995a?w=400",
                    ShelterId = shelter3
                },
                new Animal
                {
                    Name = "Mochi",
                    Species = "Cat",
                    Breed = "British Shorthair",
                    Age = 1,
                    Gender = "Female",
                    Size = "Small",
                    Description = "Mochi is a playful kitten who loves toys and sunny windows.",
                    MedicalNotes = "Dewormed and vaccinated",
                    Status = "available",
                    ImageUrl = "https://images.unsplash.com/photo-1518791841217-8f162f1e1131?w=400",
                    ShelterId = shelter4
                },
                new Animal
                {
                    Name = "Thumper",
                    Species = "Rabbit",
                    Breed = "Mini Lop",
                    Age = 2,
                    Gender = "Male",
                    Size = "Small",
                    Description = "Thumper is gentle and curious, perfect for a calm home.",
                    MedicalNotes = "Health check complete",
                    Status = "available",
                    ImageUrl = "https://images.unsplash.com/photo-1548767797-d8c844163c4c?w=400",
                    ShelterId = shelter1
                },
                new Animal
                {
                    Name = "Kiwi",
                    Species = "Bird",
                    Breed = "Budgerigar",
                    Age = 1,
                    Gender = "Female",
                    Size = "Small",
                    Description = "Kiwi is a cheerful budgie that enjoys gentle music and company.",
                    MedicalNotes = "Vet checked",
                    Status = "available",
                    ImageUrl = "https://images.unsplash.com/photo-1452570053594-1b985d6ea890?w=400",
                    ShelterId = shelter2
                },
                new Animal
                {
                    Name = "Rocky",
                    Species = "Dog",
                    Breed = "German Shepherd",
                    Age = 5,
                    Gender = "Male",
                    Size = "Large",
                    Description = "Rocky is confident and trained, great with families.",
                    MedicalNotes = "Vaccinated and house-trained",
                    Status = "available",
                    ImageUrl = "https://images.unsplash.com/photo-1518717758536-85ae29035b6d?w=400",
                    ShelterId = shelter3
                },
                new Animal
                {
                    Name = "Cleo",
                    Species = "Cat",
                    Breed = "Maine Coon",
                    Age = 4,
                    Gender = "Female",
                    Size = "Large",
                    Description = "Cleo is calm and affectionate, loves to nap in sunny spots.",
                    MedicalNotes = "Spayed and vaccinated",
                    Status = "available",
                    ImageUrl = "https://images.unsplash.com/photo-1513360371669-4adf3dd7dff8?w=400",
                    ShelterId = shelter4
                },
                new Animal
                {
                    Name = "Pepper",
                    Species = "Rabbit",
                    Breed = "Dutch Rabbit",
                    Age = 1,
                    Gender = "Female",
                    Size = "Small",
                    Description = "Pepper is gentle and curious, enjoys quiet environments.",
                    MedicalNotes = "Health check complete",
                    Status = "available",
                    ImageUrl = "https://images.unsplash.com/photo-1548767797-d8c844163c4c?w=400",
                    ShelterId = shelter1
                },
                new Animal
                {
                    Name = "Sky",
                    Species = "Bird",
                    Breed = "Cockatiel",
                    Age = 2,
                    Gender = "Male",
                    Size = "Small",
                    Description = "Sky is friendly and can whistle simple tunes.",
                    MedicalNotes = "Vet checked",
                    Status = "available",
                    ImageUrl = "https://images.unsplash.com/photo-1470115636492-6d2b56f9146d?w=400",
                    ShelterId = shelter2
                },
                new Animal
                {
                    Name = "Nala",
                    Species = "Cat",
                    Breed = "Ragdoll",
                    Age = 2,
                    Gender = "Female",
                    Size = "Medium",
                    Description = "Nala is playful and social, loves feather toys.",
                    MedicalNotes = "Vaccinated",
                    Status = "available",
                    ImageUrl = "https://images.unsplash.com/photo-1513360371669-4adf3dd7dff8?w=400",
                    ShelterId = shelter3
                },
                new Animal
                {
                    Name = "Bruno",
                    Species = "Dog",
                    Breed = "Beagle",
                    Age = 3,
                    Gender = "Male",
                    Size = "Medium",
                    Description = "Bruno is energetic and enjoys long walks and sniffing trails.",
                    MedicalNotes = "Vaccinated and microchipped",
                    Status = "available",
                    ImageUrl = "https://images.unsplash.com/photo-1517849845537-4d257902454a?w=400",
                    ShelterId = shelter4
                }
            };

            var existingNames = new HashSet<string>(
                context.Animals.Select(a => a.Name).ToList(),
                StringComparer.OrdinalIgnoreCase
            );

            var toAdd = animalsToSeed.Where(a => !existingNames.Contains(a.Name)).ToList();
            if (toAdd.Any())
            {
                context.Animals.AddRange(toAdd);
                context.SaveChanges();
            }

            var existingAnimals = context.Animals.ToList();
            foreach (var animal in existingAnimals)
            {
                var seeded = animalsToSeed.FirstOrDefault(a =>
                    string.Equals(a.Name, animal.Name, StringComparison.OrdinalIgnoreCase));
                if (seeded != null)
                {
                    animal.ShelterId = seeded.ShelterId;
                    animal.ImageUrl = seeded.ImageUrl;
                }
            }
            context.SaveChanges();

            var unassignedAnimals = context.Animals.Where(a => a.ShelterId == null).ToList();
            if (unassignedAnimals.Any())
            {
                foreach (var animal in unassignedAnimals)
                {
                    animal.ShelterId = shelter1;
                }
                context.SaveChanges();
            }
        }
    }
}
