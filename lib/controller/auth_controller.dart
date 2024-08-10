import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quick_cart/models/auth_model.dart';
import 'package:quick_cart/repo/auth_repo.dart';
import 'package:quick_cart/view/auth/forgot_password_page.dart';
import 'package:quick_cart/view/auth/sign_in_page.dart';
import 'package:quick_cart/view/auth/sign_up_page.dart';
import 'package:quick_cart/view/product/home_page.dart';
import 'package:quick_cart/view/verification/email_verification_page.dart';
import 'package:quick_cart/view/verification/otp_verification_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final AuthRepo authRepo;

  var user = AuthModel().obs;
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var fullNameController = TextEditingController();
  var phoneNumberController = TextEditingController();
  var addressController = TextEditingController();
  var isLoading = false.obs;
  var obscureText = true.obs;
  var rememberMe = false.obs;
  var profilePicturePath = ''.obs;
  var isProfilePageVisible = false.obs;
  final String avatarKey = "userAvatar";

  AuthController({required this.authRepo});

  @override
  void onInit() {
    super.onInit();
    checkRememberMe();
    fetchUserProfile();
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
        address: addressController.text,
        phone: phoneNumberController.text,
      );

      final response = await authRepo.signUp(
        signUpBody.fullName!,
        signUpBody.email!,
        signUpBody.password!,
        signUpBody.address!,
        signUpBody.phone!,
        confirmPasswordController.text,
      );

      isLoading.value = false;

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

      // Clear the controllers' text
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

  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    try {
      String token = authRepo.getUserToken();
      final response = await authRepo.getUserProfile(token);
      if (response.statusCode == 200) {
        user.value = AuthModel.fromJson(response.body['data']);
        fullNameController.text = user.value.fullName ?? '';
        emailController.text = user.value.email ?? '';
        phoneNumberController.text = user.value.phone ?? '';
        addressController.text = user.value.address ?? '';
        print('User Profile Response: ${response.body}');
        print('User: ${user.value.toJson()}');
      } else {
        _showProfilePageSnackbar('Error', 'Failed to load user profile');
      }
    } catch (e) {
      _showProfilePageSnackbar('Error', 'Failed to load user profile');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? address,
  }) async {
    isLoading.value = true;
    try {
      String token = authRepo.getUserToken();
      AuthModel updatedUser = user.value.copyWith(
        fullName: fullName ?? user.value.fullName,
        email: email ?? user.value.email,
        phone: phone ?? user.value.phone,
        address: address ?? user.value.address,
      );
      final response = await authRepo.updateUserProfile(updatedUser, token);
      if (response.statusCode == 200) {
        user.value = updatedUser;
        _showProfilePageSnackbar('Success', 'Profile updated successfully');
      } else {
        _showProfilePageSnackbar('Error', 'Failed to update profile');
      }
    } catch (e) {
      _showProfilePageSnackbar('Error', 'Failed to update profile');
    } finally {
      isLoading.value = false;
    }
  }

  // Method to refresh the avatar
  void refreshAvatar() async {
    // Generate a random name or ID for a new avatar
    String newAvatarId = generateRandomString(10); // You can use any logic here

    // Update the user avatar with the new SVG
    user.update((user) {
      user?.avatarID = newAvatarId;
    });

    // Save the new avatar ID to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(avatarKey, newAvatarId);
  }

  // Utility to generate a random string for the avatar ID
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

  // Method to update profile picture
  void updateProfilePicture(String path) {
    profilePicturePath.value = path;
  }

  // Method to load saved avatar from SharedPreferences
  Future<void> loadSavedAvatar() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedAvatar = prefs.getString(avatarKey);

    if (savedAvatar != null) {
      user.update((user) {
        user?.fullName = savedAvatar;
      });
    }
  }

  Future<void> pickProfilePicture() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        profilePicturePath.value = pickedFile.path;
        await authRepo.saveProfilePicture(pickedFile.path);
      }
    } catch (e) {
      _showProfilePageSnackbar('Error', 'Failed to pick profile picture');
    }
  }

  void _showProfilePageSnackbar(String title, String message) {
    if (isProfilePageVisible.value) {
      Get.snackbar(title, message);
    }
  }

  void navigateToSignUp() {
    Get.to(() => SignUpPage());
  }

  void navigateToSignIn() {
    Get.to(() => SignInPage());
  }

  void navigateToHomePage() {
    Get.to(() => HomePage());
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
