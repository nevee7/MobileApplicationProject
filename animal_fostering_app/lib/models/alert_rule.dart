class AlertRule {
  final int id;
  final String name;
  final String metric;
  final String comparison;
  final int threshold;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  AlertRule({
    required this.id,
    required this.name,
    required this.metric,
    required this.comparison,
    required this.threshold,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AlertRule.fromJson(Map<String, dynamic> json) {
    return AlertRule(
      id: json['id'] as int,
      name: json['name'] as String,
      metric: json['metric'] as String,
      comparison: json['comparison'] as String,
      threshold: json['threshold'] as int,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
