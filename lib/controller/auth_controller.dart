import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/view/auth/forgot_password_page.dart';
import 'package:flutter_ecommerce/view/product/home_page.dart';
import 'package:get/get.dart';
import '../repo/auth_repo.dart';
import '../view/auth/sign_in_page.dart';
import '../view/auth/sign_up_page.dart';
import '../view/verification/email_verification_page.dart';

class AuthController extends GetxController {
  final AuthRepo authRepo;

  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var fullNameController = TextEditingController();
  var phoneNumberController = TextEditingController();

  var isLoading = false.obs;
  var obscureText = true.obs;

  AuthController({required this.authRepo});

  void toggleObscureText() {
    obscureText.value = !obscureText.value;
  }

  Future<void> signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }

    isLoading.value = true;
    final response = await authRepo.signUp(
      fullNameController.text,
      emailController.text,
      passwordController.text,
      phoneNumberController.text,
    );
    isLoading.value = false;

    if (response.isOk) {
      String token = response.body['token'];
      await authRepo.saveUserToken(token);
      Get.offAll(() => const EmailVerificationPage());
    } else {
      Get.snackbar('Error', response.statusText ?? 'Unknown error');
    }
  }

  Future<void> signIn() async {
    isLoading.value = true;
    final response = await authRepo.signIn(
      emailController.text,
      passwordController.text,
    );
    isLoading.value = false;

    if (response.isOk) {
      String token = response.body['token'];
      await authRepo.saveUserToken(token);
      // Navigate to the next page or do something after successful sign-in
    } else {
      Get.snackbar('Error', response.statusText ?? 'Unknown error');
    }
  }

  void navigateToSignUp() {
    Get.to(() => SignUpPage());
  }

  void navigateToSignIn() {
    Get.to(() => SignInPage());
  }

  void navigateToHomePage() {
    Get.to(
      () => const HomePage(),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void navigateToVerifyEmail() {
    Get.to(() => const EmailVerificationPage());
  }

  void navigateToForgotPassword() {
    Get.to(() => const ForgotPasswordPage());
  }

  void navigateToSignInpAfterVerificatoin() {
    Get.to(
      () => SignUpPage(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
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
