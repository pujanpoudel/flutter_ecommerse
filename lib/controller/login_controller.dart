import 'package:flutter_ecommerce/repo/login_repo.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';

class LoginController extends GetxController implements GetxService {
  late final LoginRepo loginRepo;
  LoginController({required this.loginRepo});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool obscureText = true.obs;

  final String baseUrl = AppConstants.BASE_URL;
  final String loginUrl = AppConstants.LOGIN_URL;

  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  Future<void> login() async {
    isLoading.value = true;
    try {
      final response =
          await loginRepo.login(emailController.text, passwordController.text);
      if (response.statusCode == 200) {
        final data = response.body;
        await loginRepo.saveUserToken(data['token']);
        Get.offAllNamed('/home');
      } else {
        Get.snackbar(
          'Error',
          'Login failed. Please check your credentials.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  void navigateToSignUp() {
    Get.toNamed('/signup');
  }

  void navigateToForgotPassword() {
    Get.toNamed('/forgot-password');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
