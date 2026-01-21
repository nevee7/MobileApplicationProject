class AppNotification {
  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String? relatedEntityType;
  final int? relatedEntityId;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.relatedEntityType,
    this.relatedEntityId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      type: (json['type'] ?? 'Info') as String,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      relatedEntityType: json['relatedEntityType'] as String?,
      relatedEntityId: json['relatedEntityId'] as int?,
    );
  }
}
