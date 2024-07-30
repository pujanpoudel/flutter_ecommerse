import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repo/sign_in_repo.dart';

class SignInController extends GetxController {
  final SignInRepo signInRepo;

  SignInController({required this.signInRepo});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var obscureText = true.obs;
  var isLoading = false.obs;

  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  Future<void> login() async {
    isLoading.value = true;

    try {
      final response = await signInRepo.login(
        emailController.text,
        passwordController.text,
      );

      if (response.statusCode == 200) {
        await signInRepo.saveUserToken(response.body['token']);
        Get.offAllNamed('/home');
      } else {
        Get.snackbar('Error', 'Login failed');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
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
