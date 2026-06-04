class ProjectModel {
  final String? id;
  final String? userId;
  final String name;
  final String? description;
  final String? categoryId;
  final String priority; // 'low', 'medium', 'high'
  final DateTime? deadline;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProjectModel({
    this.id,
    this.userId,
    required this.name,
    this.description,
    this.categoryId,
    this.priority = 'medium',
    this.deadline,
    this.createdAt,
    this.updatedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      categoryId: json['category_id']?.toString(),
      priority: json['priority']?.toString() ?? 'medium',
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'].toString()).toLocal() : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()).toLocal() : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'].toString()).toLocal() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'priority': priority,
      if (deadline != null) 'deadline': deadline?.toUtc().toIso8601String(),
    };
  }

  ProjectModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? categoryId,
    String? priority,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
