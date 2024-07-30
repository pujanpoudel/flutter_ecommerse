import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';

class SignInRepo extends GetxService {
  final String baseUrl = AppConstants.BASE_URL;
  final SharedPreferences sharedPreferences;

  SignInRepo({required this.sharedPreferences});

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
}
