namespace AnimalFostering.API.Models
{
    public class Animal
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Species { get; set; }
        public string Breed { get; set; }
        public int Age { get; set; }
        public string Gender { get; set; }         // <-- Add this
        public string Size { get; set; }           // <-- Add this
        public string Description { get; set; }
        public string MedicalNotes { get; set; }   // <-- Add this
        public string Status { get; set; }
        public string ImageUrl { get; set; }
        public int ShelterId { get; set; }         // <-- Add this
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }
}