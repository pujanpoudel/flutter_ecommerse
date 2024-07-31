class SignUpBody {
  String name;
  String phone;
  String email;
  String password;
  String address;
  SignUpBody({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["f_name"] = name;
    data["phone"] = phone;
    data["email"] = email;
    data["password"] = password;
    data["address"] = address;

    return data;
  }
}
