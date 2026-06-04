class UserModel {
  final String? id;
  final String? fullName;
  final String email;
  final String? password;

  UserModel({
    this.id,
    this.fullName,
    required this.email,
    this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      fullName: json['full_name']?.toString() ?? json['fullName']?.toString(),
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      'email': email,
      if (password != null) 'password': password,
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? password,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
