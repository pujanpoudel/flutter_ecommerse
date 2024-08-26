class AuthModel {
  final int? id;
  String? fullName;
  String? phone;
  String? email;
  String? password;
  String? confirm_password;
  String? address;
  String? avatarID;
  final DateTime? createdAt;

  AuthModel({
    this.id,
    this.fullName,
    this.phone,
    this.email,
    this.password,
    this.confirm_password,
    this.address,
    this.avatarID,
    this.createdAt,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      id: json['id'],
      fullName: json['full_name'],
      phone: json['phone'],
      email: json['email'],
      password: json['password'],
      confirm_password: json['confirm_password'],
      address: json['address'],
      avatarID: json['avatar_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'password': password,
      'confirm_password': confirm_password,
      'address': address,
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
    String? confirm_password,
    String? address,
    String? avatarID,
    DateTime? createdAt,
  }) {
    return AuthModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      confirm_password: confirm_password ?? this.confirm_password,
      address: address ?? this.address,
      avatarID: avatarID ?? this.avatarID,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}