class AuthModel {
  String? avatarId;
  String? fullName;
  String? phone;
  String? email;
  String? password;
  String? confirmPassword;
  String? address;
  final DateTime? createdAt;

  AuthModel({
    this.fullName,
    this.email,
    this.phone,
    this.address,
    this.password,
    this.confirmPassword,
    this.createdAt,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      password: json['password'],
      confirmPassword: json['confirm_password'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'password': password,
      'confirm_password': confirmPassword,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  AuthModel copyWith({
    int? id,
    String? fullName,
    String? phone,
    String? email,
    String? password,
    String? confirmPassword,
    String? address,
    String? avatarID,
    DateTime? createdAt,
  }) {
    return AuthModel(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'password': password,
      'confirm_password': confirmPassword,
    };
  }
}
