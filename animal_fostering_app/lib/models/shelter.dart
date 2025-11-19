class Shelter {
  final int id;
  final String name;
  final String address;
  final String city;
  final String phone;
  final String email;
  final double latitude;
  final double longitude;
  final String description;

  Shelter({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    required this.email,
    required this.latitude,
    required this.longitude,
    required this.description,
  });

  factory Shelter.fromJson(Map<String, dynamic> json) {
    return Shelter(
      id: json['Id'] as int,
      name: json['Name'] as String,
      address: json['Address'] as String,
      city: json['City'] as String,
      phone: json['Phone'] as String,
      email: json['Email'] as String,
      latitude: (json['Latitude'] as num).toDouble(),
      longitude: (json['Longitude'] as num).toDouble(),
      description: json['Description'] as String,
    );
  }
}
