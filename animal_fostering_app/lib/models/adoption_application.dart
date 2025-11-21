import 'user.dart';
import 'animal.dart';

class AdoptionApplication {
  final int id;
  final int userId;
  final int animalId;
  final String status;
  final String? message;
  final String? adminNotes;
  final DateTime applicationDate;
  final DateTime? reviewedDate;
  final int? reviewedByAdminId;
  final User? user;
  final Animal? animal;

  AdoptionApplication({
    required this.id,
    required this.userId,
    required this.animalId,
    required this.status,
    this.message,
    this.adminNotes,
    required this.applicationDate,
    this.reviewedDate,
    this.reviewedByAdminId,
    this.user,
    this.animal,
  });

  factory AdoptionApplication.fromJson(Map<String, dynamic> json) {
    return AdoptionApplication(
      id: json['id'] as int,
      userId: json['userId'] as int,
      animalId: json['animalId'] as int,
      status: json['status'] as String,
      message: json['message'] as String?,
      adminNotes: json['adminNotes'] as String?,
      applicationDate: DateTime.parse(json['applicationDate'] as String),
      reviewedDate: json['reviewedDate'] != null 
          ? DateTime.parse(json['reviewedDate'] as String) 
          : null,
      reviewedByAdminId: json['reviewedByAdminId'] as int?,
      user: json['user'] != null 
          ? User.fromJson(json['user'] as Map<String, dynamic>) 
          : null,
      animal: json['animal'] != null 
          ? Animal.fromJson(json['animal'] as Map<String, dynamic>) 
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'animalId': animalId,
    'status': status,
    'message': message,
    'adminNotes': adminNotes,
    'applicationDate': applicationDate.toIso8601String(),
    'reviewedDate': reviewedDate?.toIso8601String(),
    'reviewedByAdminId': reviewedByAdminId,
  };
}