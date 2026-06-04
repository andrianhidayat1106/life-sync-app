class TaskModel {
  final String? id;
  final String? userId;
  final String? projectId;
  final String? categoryId;
  final String title;
  final String? description;
  final String priority; // 'low', 'medium', 'high'
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? finishedAt;

  TaskModel({
    this.id,
    this.userId,
    this.projectId,
    this.categoryId,
    required this.title,
    this.description,
    this.priority = 'medium',
    this.dueDate,
    this.isCompleted = false,
    this.createdAt,
    this.updatedAt,
    this.finishedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      projectId: json['project_id']?.toString(),
      categoryId: json['category_id']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      priority: json['priority']?.toString() ?? 'medium',
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date'].toString()) : null,
      isCompleted: json['is_completed'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'].toString()) : null,
      finishedAt: json['finished_at'] != null ? DateTime.parse(json['finished_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (projectId != null) 'project_id': projectId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'priority': priority,
      'due_date': dueDate?.toIso8601String(),
      'is_completed': isCompleted,
      'finished_at': finishedAt?.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? userId,
    String? projectId,
    String? categoryId,
    String? title,
    String? description,
    String? priority,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? finishedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }
}
