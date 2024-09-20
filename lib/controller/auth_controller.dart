import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multiavatar/multiavatar.dart';
import 'package:quick_cart/models/auth_model.dart';
import 'package:quick_cart/repo/auth_repo.dart';
import 'package:quick_cart/view/auth/forgot_password_page.dart';
import 'package:quick_cart/view/auth/sign_in_page.dart';
import 'package:quick_cart/view/auth/sign_up_page.dart';
import 'package:quick_cart/view/product/home_page.dart';
import 'package:quick_cart/view/profile/profile_page.dart';
import 'package:quick_cart/view/verification/email_verification_page.dart';
import 'package:quick_cart/view/verification/otp_verification_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final AuthRepo authRepo;

  var user = AuthModel().obs;
  var fullNameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var phoneNumberController = TextEditingController();
  var addressController = TextEditingController();
  var isLoading = false.obs;
  var obscureText = true.obs;
  var rememberMe = false.obs;
  var profilePicturePath = ''.obs;
  var isProfilePageVisible = false.obs;
  String avatarKey = "userAvatar";

  AuthController({required this.authRepo});

  @override
  void onInit() {
    super.onInit();
    checkRememberMe();
    loadUserProfile();
    loadProfilePicture();
    loadSavedAvatar();
  }

  void checkRememberMe() {
    if (authRepo.isRememberMeChecked()) {
      emailController.text = authRepo.getUserEmail();
      passwordController.text = authRepo.getUserPassword();
      rememberMe.value = true;
    }
  }

  void loadProfilePicture() {
    profilePicturePath.value = authRepo.getProfilePicture() ?? '';
  }

  void toggleObscureText() {
    obscureText.value = !obscureText.value;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  Future<void> signUp() async {
    isLoading.value = true;
    try {
      final signUpBody = AuthModel(
        fullName: fullNameController.text,
        email: emailController.text,
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
        phone: phoneNumberController.text,
        address: addressController.text,
      );

      final response = await authRepo.signUp(
        signUpBody.fullName!,
        signUpBody.email!,
        signUpBody.password!,
        signUpBody.confirmPassword!,
        signUpBody.phone!,
        signUpBody.address!,
      );

      isLoading.value = false;
      navigateToVerifyEmail();

      if (response.statusCode == 200) {
        final data = response.body['data'];
        final accessToken = data['access_token'] as String?;
        final refreshToken = data['refresh_token'] as String?;

        if (accessToken != null && refreshToken != null) {
          await authRepo.saveUserToken(accessToken);
          navigateToVerifyEmail();
        } else {
          Get.snackbar('Error', 'Invalid response data. Please try again.');
        }
      } else {
        Get.snackbar('Error', response.statusText ?? 'Unknown error');
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to sign up. Please try again.');
    }
  }

  Future<void> signIn() async {
    isLoading.value = true;
    try {
      final response = await authRepo.signIn(
        emailController.text,
        passwordController.text,
        rememberMe.value,
      );
      isLoading.value = false;

      if (response.statusCode == 200) {
        final data = response.body['data'];
        final accessToken = data['access_token'] as String?;
        final refreshToken = data['refresh_token'] as String?;

        if (accessToken != null && refreshToken != null) {
          await authRepo.saveUserToken(accessToken);
          navigateToHomePage();
        } else {
          Get.snackbar('Error', 'Invalid response data. Please try again.');
        }
      } else if (response.statusCode == 401) {
        Get.snackbar('Error', 'Invalid email or password');
      } else {
        Get.snackbar('Error', response.statusText ?? 'Unknown error');
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to sign in. Please try again.');
    }
  }

  Future<void> signOut() async {
    await authRepo.clearUserToken();

    if (!rememberMe.value) {
      await authRepo.clearUserEmail();
      await authRepo.clearUserPassword();

      emailController.clear();
      passwordController.clear();
    }
    navigateToSignIn();
  }

  Future<void> resetPassword() async {
    isLoading.value = true;
    try {
      final response = await authRepo.resetPassword(emailController.text);
      isLoading.value = false;

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Password reset link sent to your email');
        navigateToOTPVerificationPage();
      } else {
        Get.snackbar('Error', response.statusText ?? 'Unknown error');
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to reset password. Please try again.');
    }
  }

  void loadUserProfile() async {
    String token = authRepo.getUserToken();
    Response response = await authRepo.getUserProfile(token);
    print('User Full Name: ${user.value.fullName}');
    print('User Email: ${user.value.email}');
    print('User Phone: ${user.value.phone}');
    print('User Address: ${user.value.address}');

    if (response.statusCode == 200) {
      user.value = AuthModel.fromJson(response.body);
      fullNameController.text = user.value.fullName ?? '';
      emailController.text = user.value.email ?? '';
      phoneNumberController.text = user.value.phone ?? '';
      addressController.text = user.value.address ?? '';
    } else {
      Get.snackbar('Error', 'Failed to load user profile');
    }
  }

  void updateProfile() async {
    user.value = user.value.copyWith(
      fullName: fullNameController.text,
      email: emailController.text,
      phone: phoneNumberController.text,
      address: addressController.text,
    );

    String token = authRepo.getUserToken();
    Response response = await authRepo.updateUserProfile(user.value, token);
    if (response.statusCode == 200) {
      Get.snackbar(
          'Profile Updated', 'Your profile has been successfully updated');
    } else {
      Get.snackbar('Error', 'Failed to update profile');
    }
  }

  void refreshAvatar() {
    String newAvatar = multiavatar(user.value.fullName ?? 'User');
    user.update((val) {
      val?.fullName = newAvatar;
    });
    update();
  }

  String generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();

    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  void updateProfilePicture(String path) {
    profilePicturePath.value = path;
    user.update((val) {
      val?.fullName = path;
    });
    update();
  }

  void clearProfilePicture() {
    profilePicturePath.value = '';
    String defaultAvatar = multiavatar(user.value.fullName ?? 'User');
    user.update((val) {
      val?.fullName = defaultAvatar;
    });
    update();
  }

  Future<void> loadSavedAvatar() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedAvatar = prefs.getString(avatarKey);

    if (savedAvatar != null) {
      user.update((user) {
        user?.fullName = savedAvatar;
      });
    }
  }

  void _showProfilePageSnackbar(String title, String message) {
    if (isProfilePageVisible.value) {
      Get.snackbar(title, message);
    }
  }

  void navigateToSignUp() {
    Get.to(() => const SignUpPage());
  }

  void navigateToProfilePage() {
    Get.to(() => const ProfilePage());
  }

  void navigateToSignIn() {
    Get.to(() => SignInPage());
  }

  void navigateToHomePage() {
    Get.to(() => const HomePage());
  }

  void navigateToVerifyEmail() {
    Get.to(() => const EmailVerificationPage());
  }

  void navigateToForgotPassword() {
    Get.to(() => const ForgotPasswordPage());
  }

  void navigateToOTPVerificationPage() {
    Get.to(() => OTPVerificationPage());
  }

  Future<void> updateEmail(String newEmail) async {
    isLoading.value = true;
    try {
      await authRepo.saveUserEmail(newEmail);
      emailController.text = newEmail;
      Get.snackbar('Success', 'Email updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update email. Please try again.');
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
    addressController.dispose();
    super.onClose();
  }
}
