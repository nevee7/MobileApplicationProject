class Animal {
  final int id;
  final String name;
  final String species;
  final String breed;
  final int age;
  final String gender;
  final String? size;
  final String description;
  final String? medicalNotes;
  final String status;
  final String? imageUrl;
  final int? shelterId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Animal({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.gender,
    this.size,
    required this.description,
    this.medicalNotes,
    required this.status,
    this.imageUrl,
    this.shelterId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Animal.fromJson(Map<String, dynamic> json) => Animal(
        id: json['Id'] ?? 0,
        name: json['Name'] ?? '',
        species: json['Species'] ?? '',
        breed: json['Breed'] ?? '',
        age: json['Age'] ?? 0,
        gender: json['Gender'] ?? 'Unknown',
        size: json['Size'], // nullable
        description: json['Description'] ?? '',
        medicalNotes: json['MedicalNotes'], // nullable
        status: json['Status'] ?? 'available',
        imageUrl: json['ImageUrl'], // nullable
        shelterId: json['ShelterId'], // nullable int
        createdAt: DateTime.parse(json['CreatedAt'] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(json['UpdatedAt'] ?? DateTime.now().toIso8601String()),
      );

  Map<String, dynamic> toJson() => {
        'Id': id,
        'Name': name,
        'Species': species,
        'Breed': breed,
        'Age': age,
        'Gender': gender,
        'Size': size,
        'Description': description,
        'MedicalNotes': medicalNotes,
        'Status': status,
        'ImageUrl': imageUrl,
        'ShelterId': shelterId,
        'CreatedAt': createdAt.toIso8601String(),
        'UpdatedAt': updatedAt.toIso8601String(),
      };
}
