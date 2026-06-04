class WalletModel {
  final int? id;
  final DateTime? createdAt;
  final String? userId;
  final String? name;
  final String? type;
  final String? icon;
  final String? colorHex;
  final double? balance;

  WalletModel({
    this.id,
    this.createdAt,
    this.userId,
    this.name,
    this.type,
    this.icon,
    this.colorHex,
    this.balance,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? json['id'] as int? : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      userId: json['user_id']?.toString(),
      name: json['name']?.toString(),
      type: json['type']?.toString(),
      icon: json['icon']?.toString(),
      colorHex: json['color_hex']?.toString(),
      balance: json['balance'] != null
          ? (json['balance'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (icon != null) 'icon': icon,
      if (colorHex != null) 'color_hex': colorHex,
      if (balance != null) 'balance': balance,
    };
  }

  WalletModel copyWith({
    int? id,
    DateTime? createdAt,
    String? userId,
    String? name,
    String? type,
    String? icon,
    String? colorHex,
    double? balance,
  }) {
    return WalletModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      colorHex: colorHex ?? this.colorHex,
      balance: balance ?? this.balance,
    );
  }
}
