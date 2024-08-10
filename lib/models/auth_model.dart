class AuthModel {
  final int? id;
  String? fullName;
  String? phone;
  String? email;
  String? password;
  String? address;
  String? avatarID;//for desplaying below avatar

  final DateTime? createdAt;

  AuthModel({
    this.id,
    this.fullName,
    this.phone,
    this.email,
    this.password,
    this.address,
    this.createdAt,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      id: json['id'],
      fullName: json['full_name'],
      phone: json['phone'],
      email: json['email'],
      password: json['password'],
      address: json['address'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'password': password,
      'address': address,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  AuthModel copyWith({
    int? id,
    String? fullName,
    String? phone,
    String? email,
    String? password,
    String? address,
    DateTime? createdAt,
  }) {
    return AuthModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
