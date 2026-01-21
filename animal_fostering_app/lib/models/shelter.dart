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
  final double? rating; // Add this
  final String? website; // Add this
  final String? openingHours; // Add this
  final String? source; // Add this - "Local" or "GooglePlaces"
  final bool? isActive;

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
    this.rating,
    this.website,
    this.openingHours,
    this.source,
    this.isActive,
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
      rating: json['Rating'] != null ? (json['Rating'] as num).toDouble() : null,
      website: (json['Website'] ?? json['website']) as String?,
      openingHours: (json['OpeningHours'] ?? json['openingHours']) as String?,
      source: (json['Source'] ?? json['source']) as String?,
      isActive: (json['IsActive'] ?? json['isActive']) as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'Id': id,
    'Name': name,
    'Address': address,
    'City': city,
    'Phone': phone,
    'Email': email,
    'Latitude': latitude,
    'Longitude': longitude,
    'Description': description,
    'Rating': rating,
    'Website': website,
    'OpeningHours': openingHours,
    'Source': source,
    'IsActive': isActive,
  };
}
