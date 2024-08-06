class UserModel {
  final int? id;
  final String? fullName;
  final String? email;
  final String? phone;
  final DateTime? createdAt;

  UserModel({
    this.id,
    this.fullName,
    this.email,
    this.phone,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? fullName,
    String? email,
    String? phone,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt,
    );
  }
}