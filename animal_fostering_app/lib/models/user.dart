// lib/models/user.dart
class AppUser {
  final String email;
  final bool isAdmin;

  AppUser({required this.email, this.isAdmin = false});

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        email: (json['email'] ?? json['Email'] ?? '') as String,
        isAdmin: (json['isAdmin'] ?? json['IsAdmin'] ?? false) as bool,
      );
}
