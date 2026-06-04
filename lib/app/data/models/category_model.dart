class CategoryModel {
  final String? id;
  final String? userId;
  final String name;
  final String type;
  final String icon;
  final String colorHex;
  final String? description;

  CategoryModel({
    this.id,
    this.userId,
    required this.name,
    required this.type,
    required this.icon,
    required this.colorHex,
    this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      icon: json['icon']?.toString() ?? 'help',
      colorHex: json['color_hex']?.toString() ?? '#FF6B7280',
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': int.tryParse(id!) ?? id,
      if (userId != null) 'user_id': userId,
      'name': name,
      'type': type,
      'icon': icon,
      'color_hex': colorHex,
      if (description != null) 'description': description,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    String? icon,
    String? colorHex,
    String? description,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      colorHex: colorHex ?? this.colorHex,
      description: description ?? this.description,
    );
  }
}
