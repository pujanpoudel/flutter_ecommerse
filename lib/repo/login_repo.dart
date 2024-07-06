import 'package:flutter_ecommerce/utils/app_constants.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginRepo extends GetxService {
  final String baseUrl = AppConstants.BASE_URL;
  final SharedPreferences sharedPreferences;

  LoginRepo({required this.sharedPreferences});

  Future<Response<dynamic>> login(String email, String password) async {
    try {
      final response = await GetConnect().post(
        '$baseUrl/login/',
        {
          'email': email,
          'password': password,
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

  Future<Response<dynamic>> getUserInfo() async {
    try {
      final token = getUserToken();
      final response = await GetConnect().get(
        '$baseUrl/user/',
        headers: {'Authorization': 'Token $token'},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response<dynamic>> refreshToken() async {
    try {
      final token = getUserToken();
      final response = await GetConnect().post(
        '$baseUrl/token/refresh/',
        {},
        headers: {'Authorization': 'Token $token'},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response<dynamic>> logout() async {
    try {
      final token = getUserToken();
      final response = await GetConnect().post(
        '$baseUrl/logout/',
        {},
        headers: {'Authorization': 'Token $token'},
      );
      await clearUserToken();
      return response;
    } catch (e) {
      rethrow;
    }
  }
}