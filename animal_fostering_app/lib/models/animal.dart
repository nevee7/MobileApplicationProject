class Animal {
  final int? id;
  final String name;
  final String species;
  final String breed;
  final int age;
  final String description;
  final String imageUrl;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Animal({
    this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.description,
    required this.imageUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'],
      name: json['name'],
      species: json['species'],
      breed: json['breed'],
      age: json['age'],
      description: json['description'],
      imageUrl: json['imageUrl'] ?? '',
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'description': description,
      'imageUrl': imageUrl,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}