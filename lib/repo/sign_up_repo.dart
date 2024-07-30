import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_constants.dart';

class SignUpRepo extends GetxService {
  final String baseUrl = AppConstants.BASE_URL;
  final SharedPreferences sharedPreferences;

  SignUpRepo({required this.sharedPreferences});

  Future<Response<dynamic>> signUp(String fullName, String email,
      String password, String phoneNumber) async {
    try {
      final response = await GetConnect().post(
        '$baseUrl+signup/',
        {
          'full_name': fullName,
          'email': email,
          'password': password,
          'confirm_password': password,
          'phone': phoneNumber,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> saveUserToken(String token) async {
    return await sharedPreferences.setString('user_token', token);
  }

  String getUserToken() {
    return sharedPreferences.getString('user_token') ?? "";
  }

  bool isLoggedIn() {
    return sharedPreferences.containsKey('user_token');
  }

  Future<bool> clearUserToken() async {
    return await sharedPreferences.remove('user_token');
  }
}
