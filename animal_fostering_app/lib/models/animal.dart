// lib/models/animal.dart
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

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: (json['Id'] ?? json['id'] ?? 0) as int,
      name: (json['Name'] ?? json['name'] ?? '') as String,
      species: (json['Species'] ?? json['species'] ?? '') as String,
      breed: (json['Breed'] ?? json['breed'] ?? '') as String,
      age: (json['Age'] ?? json['age'] ?? 0) as int,
      gender: (json['Gender'] ?? json['gender'] ?? 'Unknown') as String,
      size: (json['Size'] ?? json['size']) as String?,
      description: (json['Description'] ?? json['description'] ?? '') as String,
      medicalNotes: (json['MedicalNotes'] ?? json['medicalNotes']) as String?,
      status: (json['Status'] ?? json['status'] ?? 'available') as String,
      imageUrl: (json['ImageUrl'] ?? json['imageUrl']) as String?,
      shelterId: (json['ShelterId'] ?? json['shelterId']) as int?,
      createdAt: DateTime.tryParse((json['CreatedAt'] ?? json['createdAt'])?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse((json['UpdatedAt'] ?? json['updatedAt'])?.toString() ?? '') ?? DateTime.now(),
    );
  }

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
