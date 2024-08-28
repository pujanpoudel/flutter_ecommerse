class AuthModel {
  late final
  String? fullName;
  String? phone;
  String? email;
  String? password;
  String? confirmPassword;
  String? address;
  String? avatarID;
  final DateTime? createdAt;

  AuthModel({
    this.fullName,
    this.email,
    this.phone,
    this.address,
    this.password,
    this.confirmPassword,
    this.avatarID,
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
      avatarID: json['avatar_id'],
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
      'avatar_id': avatarID,
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
      avatarID: avatarID ?? this.avatarID,
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
