class TransactionModel {
  final String? id;
  final String? userId;
  final String walletId;
  final String categoryId;
  final double amount;
  final String type; // 'income' or 'outcome'
  final DateTime transactionDate;
  final String? notes;

  // Join fields
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColorHex;
  final String? walletName;

  TransactionModel({
    this.id,
    this.userId,
    required this.walletId,
    required this.categoryId,
    required this.amount,
    required this.type,
    required this.transactionDate,
    this.notes,
    this.categoryName,
    this.categoryIcon,
    this.categoryColorHex,
    this.walletName,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // Handling nested JSON maps if fetched via Supabase joins e.g. categories(name, icon, color_hex)
    final categoryData = json['categories'] is Map ? json['categories'] as Map<String, dynamic> : null;
    final walletData = json['wallets'] is Map ? json['wallets'] as Map<String, dynamic> : null;

    return TransactionModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      walletId: json['wallet_id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : 0.0,
      type: json['type']?.toString() ?? 'outcome',
      transactionDate: json['transaction_date'] != null
          ? DateTime.parse(json['transaction_date'].toString()).toLocal()
          : DateTime.now(),
      notes: json['notes']?.toString(),
      categoryName: categoryData?['name']?.toString(),
      categoryIcon: categoryData?['icon']?.toString(),
      categoryColorHex: categoryData?['color_hex']?.toString(),
      walletName: walletData?['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': int.tryParse(id!) ?? id,
      if (userId != null) 'user_id': userId,
      'wallet_id': int.tryParse(walletId) ?? walletId,
      'category_id': int.tryParse(categoryId) ?? categoryId,
      'amount': amount,
      'type': type,
      'transaction_date': transactionDate.toUtc().toIso8601String(),
      if (notes != null) 'notes': notes,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? walletId,
    String? categoryId,
    double? amount,
    String? type,
    DateTime? transactionDate,
    String? notes,
    String? categoryName,
    String? categoryIcon,
    String? categoryColorHex,
    String? walletName,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      walletId: walletId ?? this.walletId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      transactionDate: transactionDate ?? this.transactionDate,
      notes: notes ?? this.notes,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColorHex: categoryColorHex ?? this.categoryColorHex,
      walletName: walletName ?? this.walletName,
    );
  }
}
