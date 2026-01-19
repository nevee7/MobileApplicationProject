// adoption_application.dart
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

  // Add status check methods
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isWithdrawn => status.toLowerCase() == 'withdrawn';

  // Copy with method for updates
  AdoptionApplication copyWith({
    int? id,
    int? userId,
    int? animalId,
    String? status,
    String? message,
    String? adminNotes,
    DateTime? applicationDate,
    DateTime? reviewedDate,
    int? reviewedByAdminId,
    User? user,
    Animal? animal,
  }) {
    return AdoptionApplication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      animalId: animalId ?? this.animalId,
      status: status ?? this.status,
      message: message ?? this.message,
      adminNotes: adminNotes ?? this.adminNotes,
      applicationDate: applicationDate ?? this.applicationDate,
      reviewedDate: reviewedDate ?? this.reviewedDate,
      reviewedByAdminId: reviewedByAdminId ?? this.reviewedByAdminId,
      user: user ?? this.user,
      animal: animal ?? this.animal,
    );
  }

  // Add fromJson method
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

  // Add toJson method
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
    // Note: We don't include user and animal objects in toJson
    // to avoid circular references when sending to API
  };
}