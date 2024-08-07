import 'package:get/get.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';

class UserRepo extends GetxService {
  final String baseUrl = AppConstants.BASE_URL;

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

  Future<Response<dynamic>> updateUserProfile(UserModel user, String token) async {
    try {
      final response = await GetConnect().put(
        '$baseUrl/accounts/me',
        user.toJson(),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response;
    } catch (e) {
      print('UpdateUserProfile Error: $e');
      rethrow;
    }
  }
}
