import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';

class AuthRepo extends GetxService {
  final String baseUrl = AppConstants.BASE_URL;
  final SharedPreferences sharedPreferences;

  AuthRepo({required this.sharedPreferences});

  Future<Response<dynamic>> signUp(String fullName, String email,
      String password, String address, String phoneNumber) async {
    try {
      final response = await GetConnect().post(
        '$baseUrl/signup',
        {
          'full_name': fullName,
          'email': email,
          'password': password,
          'address': address,
          'confirm_password': password,
          'phone': phoneNumber,
        },
      );

      print('SignUp Response code: ${response.statusCode}');
      print('SignUp Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        await saveUserEmail(email);
      }

      return response;
    } catch (e) {
      print('SignUp Error: $e');
      rethrow;
    }
  }

  Future<Response<dynamic>> signIn(
      String email, String password, bool rememberMe) async {
    try {
      final response = await GetConnect().post(
        '$baseUrl/login',
        {
          'email': email,
          'password': password,
        },
      );

      print('SignIn Response code: ${response.statusCode}');
      print('SignIn Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        await saveUserEmail(email);
        if (rememberMe) {
          await saveUserPassword(password);
        } else {
          await clearUserPassword();
        }
      }

      return response;
    } catch (e) {
      print('SignIn Error: $e');
      rethrow;
    }
  }

  Future<bool> saveUserEmail(String email) async {
    return await sharedPreferences.setString('user_email', email);
  }

  String getUserEmail() {
    return sharedPreferences.getString('user_email') ?? "";
  }

  Future<bool> saveUserPassword(String password) async {
    return await sharedPreferences.setString('user_password', password);
  }

  String getUserPassword() {
    return sharedPreferences.getString('user_password') ?? "";
  }

  Future<bool> clearUserPassword() async {
    return await sharedPreferences.remove('user_password');
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

  bool isRememberMeChecked() {
    return sharedPreferences.containsKey('user_password');
  }
}
