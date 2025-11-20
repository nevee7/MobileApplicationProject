// lib/models/shelter.dart
class Shelter {
  final int id;
  final String name;
  final String address;
  final String? city;
  final String? phone;
  final String? email;
  final double? latitude;
  final double? longitude;
  final String? description;

  Shelter({
    required this.id,
    required this.name,
    required this.address,
    this.city,
    this.phone,
    this.email,
    this.latitude,
    this.longitude,
    this.description,
  });

  factory Shelter.fromJson(Map<String, dynamic> json) {
    return Shelter(
      id: (json['Id'] ?? json['id'] ?? 0) as int,
      name: (json['Name'] ?? json['name'] ?? '') as String,
      address: (json['Address'] ?? json['address'] ?? '') as String,
      city: (json['City'] ?? json['city']) as String?,
      phone: (json['Phone'] ?? json['phone']) as String?,
      email: (json['Email'] ?? json['email']) as String?,
      latitude: json['Latitude'] != null ? (json['Latitude'] as num).toDouble() : null,
      longitude: json['Longitude'] != null ? (json['Longitude'] as num).toDouble() : null,
      description: (json['Description'] ?? json['description']) as String?,
    );
  }
}
