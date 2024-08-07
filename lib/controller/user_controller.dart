import 'package:get/get.dart';
import '../models/user_model.dart';
import '../repo/user_repo.dart';
import '../repo/auth_repo.dart';
import 'auth_controller.dart';

class UserController extends GetxController {
  final UserRepo userRepo;
  final AuthRepo authRepo;
  final AuthController authController = Get.find<AuthController>();

  var user = UserModel().obs;
  var isLoading = false.obs;

  UserController({required this.userRepo, required this.authRepo});

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    isLoading(true);
    try {
      String token = authRepo.getUserToken();
      final response = await userRepo.getUserProfile(token);
      if (response.statusCode == 200) {
        user.value = UserModel.fromJson(response.body['data']);
      } else {
        Get.snackbar('Error', 'Failed to load user profile');
      }
    } catch (e) {
      print('FetchUserProfile Error: $e');
      Get.snackbar('Error', 'Failed to load user profile');
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateUserProfile({
    String? fullName,
    String? email,
    String? phone,
  }) async {
    isLoading(true);
    try {
      String token = authRepo.getUserToken();
      UserModel updatedUser = user.value.copyWith(
        fullName: fullName ?? user.value.fullName,
        email: email ?? user.value.email,
        phone: phone ?? user.value.phone,
      );
      final response = await userRepo.updateUserProfile(updatedUser, token);
      if (response.statusCode == 200) {
        user.value = updatedUser;
        Get.snackbar('Success', 'Profile updated successfully');
      } else {
        Get.snackbar('Error', 'Failed to update profile');
      }
    } catch (e) {
      print('UpdateUserProfile Error: $e');
      Get.snackbar('Error', 'Failed to update profile');
    } finally {
      isLoading(false);
    }
  }

  String get fullName => user.value.fullName ?? '';
  String get email => user.value.email ?? '';
  String get phone => user.value.phone ?? '';
}
