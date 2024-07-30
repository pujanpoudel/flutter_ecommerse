import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repo/sign_up_repo.dart';

class SignUpController extends GetxController {
  final SignUpRepo signUpRepo;

  SignUpController({required this.signUpRepo});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneNumberController = TextEditingController();

  var obscureText = true.obs;
  var isLoading = false.obs;

  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  Future<void> signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }

    isLoading.value = true;

    try {
      final response = await signUpRepo.signUp(
        fullNameController.text,
        emailController.text,
        passwordController.text,
        phoneNumberController.text,
      );

      if (response.statusCode == 200) {
        Get.offAllNamed('/signIn');
      } else {
        Get.snackbar('Error', 'Sign up failed');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
 

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fullNameController.dispose();
    phoneNumberController.dispose();
    super.onClose();
  }
}
