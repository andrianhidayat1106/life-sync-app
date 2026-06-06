class NotificationModel {
  final String? id;
  final String? userId;
  final String title;
  final String body;
  final String? type;
  final String? icon;
  final bool isUnread;
  final DateTime? createdAt;

  NotificationModel({
    this.id,
    this.userId,
    required this.title,
    required this.body,
    this.type,
    this.icon,
    this.isUnread = true,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      type: json['type']?.toString(),
      icon: json['icon']?.toString(),
      isUnread: json['is_unread'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString()).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'title': title,
      'body': body,
      if (type != null) 'type': type,
      if (icon != null) 'icon': icon,
      'is_unread': isUnread,
      if (createdAt != null) 'created_at': createdAt?.toUtc().toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? type,
    String? icon,
    bool? isUnread,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      isUnread: isUnread ?? this.isUnread,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
