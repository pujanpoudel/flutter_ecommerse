import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repo/auth_repo.dart';
import '../view/auth/forgot_password_page.dart';
import '../view/auth/sign_in_page.dart';
import '../view/auth/sign_up_page.dart';
import '../view/product/home_page.dart';
import '../view/verification/email_verification_page.dart';

class AuthController extends GetxController {
  final AuthRepo authRepo;

  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var fullNameController = TextEditingController();
  var phoneNumberController = TextEditingController();
  var addressController = TextEditingController();

  var isLoading = false.obs;
  var obscureText = true.obs;
  var rememberMe = false.obs;

  AuthController({required this.authRepo});

  @override
  void onInit() {
    super.onInit();
    checkRememberMe();
  }

  void checkRememberMe() {
    if (authRepo.isRememberMeChecked()) {
      emailController.text = authRepo.getUserEmail();
      passwordController.text = authRepo.getUserPassword();
      rememberMe.value = true;
    }
  }

  void toggleObscureText() {
    obscureText.value = !obscureText.value;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
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
      addressController.text,
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
      rememberMe.value,
    );
    isLoading.value = false;

    if (response.isOk) {
      String token = response.body['token'];
      await authRepo.saveUserToken(token);
      navigateToHomePage();
    } else {
      Get.snackbar('Error', response.statusText ?? 'Unknown error');
    }
  }

  Future<void> signOut() async {
    await authRepo.clearUserToken();
    if (!rememberMe.value) {
      await authRepo.clearUserPassword();
    }
    navigateToSignIn();
  }

  void navigateToSignUp() {
    Get.to(() => SignUpPage(),
     transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,);
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

  void navigateToSignInAfterVerification() {
    Get.to(
      () => SignInPage(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> updateEmail(String newEmail) async {
    isLoading.value = true;
    // Implement the API call to update email
    // For now, we'll just update it locally
    await authRepo.saveUserEmail(newEmail);
    emailController.text = newEmail;
    isLoading.value = false;
    Get.snackbar('Success', 'Email updated successfully');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fullNameController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    super.onClose();
  }
}