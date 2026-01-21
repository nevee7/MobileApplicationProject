class ReportDefinition {
  final int id;
  final String name;
  final String? description;
  final String metric;
  final String? filtersJson;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReportDefinition({
    required this.id,
    required this.name,
    this.description,
    required this.metric,
    this.filtersJson,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReportDefinition.fromJson(Map<String, dynamic> json) {
    return ReportDefinition(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      metric: json['metric'] as String,
      filtersJson: json['filtersJson'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
