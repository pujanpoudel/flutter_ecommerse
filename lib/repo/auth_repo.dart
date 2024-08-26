import 'package:get/get.dart';
import 'package:quick_cart/models/auth_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';

class AuthRepo extends GetxService {
  final String baseUrl = AppConstants.BASE_URL;
  final SharedPreferences sharedPreferences;

  AuthRepo({required this.sharedPreferences});

  Future<Response<dynamic>> signUp(
      String fullName,
      String email,
      String password,
      String confirmPassword,
      String address,
      String phoneNumber) async {
    try {
      final response = await GetConnect().post(
        '$baseUrl/signup',
        AuthModel(
          fullName: fullName,
          phone: phoneNumber,
          email: email,
          password: password,
          confirm_password: confirmPassword,
          address: address,
        ).toJson(),
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

  Future<Response<dynamic>> resetPassword(String email) async {
    try {
      final response = await GetConnect().post(
        '$baseUrl/forget/password',
        {
          'email': email,
        },
      );

      print('Reset Password Response code: ${response.statusCode}');
      print('Reset Password Response body: ${response.body}');

      return response;
    } catch (e) {
      print('Reset Password Error: $e');
      rethrow;
    }
  }

  Future<Response<dynamic>> getUserProfile(String token) async {
    try {
      final response = await GetConnect().get(
        '$baseUrl/accounts/me',
        headers: {'Authorization': 'Bearer $token'},
      );
      return response;
    } catch (e) {
      print('GetUserProfile Error: $e');
      rethrow;
    }
  }

  Future<Response<dynamic>> updateUserProfile(
      AuthModel user, String token) async {
    try {
      final response = await GetConnect().put(
        '$baseUrl/accounts/update',
        user.toJson(),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response;
    } catch (e) {
      print('UpdateUserProfile Error: $e');
      rethrow;
    }
  }

  Future<bool> saveProfilePicture(String path) async {
    return await sharedPreferences.setString('profile_picture', path);
  }

  String? getProfilePicture() {
    return sharedPreferences.getString('profile_picture');
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

  Future<bool> clearUserEmail() async {
    return await sharedPreferences.remove('user_email');
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

  Future<void> signOut({required bool rememberMe}) async {
    await clearUserToken();
    if (!rememberMe) {
      await clearUserEmail();
      await clearUserPassword();
    }
  }
}
