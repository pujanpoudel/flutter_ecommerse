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
    String phoneNumber,
    String address,
  ) async {
    try {
      final response = await GetConnect().post(
        '$baseUrl/signup',
        AuthModel(
          fullName: fullName,
          email: email,
          password: password,
          confirmPassword: confirmPassword,
          phone: phoneNumber,
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

  Future<AuthModel?> getUserProfile(String token) async {
    try {
      if (token.isEmpty) {
        throw Exception('User token is missing.');
      }

      final response = await GetConnect().get(
        '$baseUrl/me',
        headers: {'Authorization': 'Bearer $token'},
      );

      print('GetUserProfile Response code: ${response.statusCode}');
      print('GetUserProfile Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userProfile = AuthModel.fromJson(response.body['data']);
        return userProfile;
      } else {
        throw Exception('Failed to fetch user profile: ${response.statusText}');
      }
    } catch (e) {
      print('GetUserProfile Error: $e');
      rethrow;
    }
  }

  Future<Response<dynamic>> updateUserProfile(
    AuthModel value, {
    required String fullName,
    required String phone,
    required String address,
  }) async {
    try {
      String token = getUserToken();

      if (token.isEmpty) {
        throw Exception('User token is missing.');
      }

      AuthModel updatedUser = AuthModel(
        fullName: fullName,
        phone: phone,
        address: address,
      );

      final response = await GetConnect().put(
        '$baseUrl/update',
        updatedUser.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('UpdateUserProfile Response code: ${response.statusCode}');
      print('UpdateUserProfile Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Failed to update profile: ${response.statusText}');
      }
    } catch (e) {
      print('UpdateUserProfile Error: $e');
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
