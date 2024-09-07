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
      print('Token: $token');

      final response = await authRepo.getUserProfile(token);
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var data = response.body['data'];
        print('Data from response: $data');

        if (data != null) {
          // user.value = AuthModel.fromJson(data);
          user.value = AuthModel(
              fullName: "John Doe",
              email: "john@example.com",
              phone: "1234567890");
          fullNameController.text = user.value.fullName ?? '';
          emailController.text = user.value.email ?? '';
          phoneNumberController.text = user.value.phone ?? '';
          addressController.text = user.value.address ?? '';
          print('User: ${user.value.toJson()}');
        } else {
          print('No data found in the response body');
          _showProfilePageSnackbar('Error', 'Failed to load user profile');
        }
      } else {
        print('Failed to load profile, status code: ${response.statusCode}');
        _showProfilePageSnackbar('Error', 'Failed to load user profile');
      }
    } catch (e) {
      print('Exception occurred: $e');
      _showProfilePageSnackbar('Error', 'Failed to load user profile');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    isLoading.value = true;
    try {
      String token = authRepo.getUserToken();
      AuthModel updatedUser = user.value.copyWith(
        fullName: fullNameController.text,
        email: emailController.text,
        phone: phoneNumberController.text,
        address: addressController.text,
      );

      final response = await authRepo.updateUserProfile(updatedUser, token);
      if (response.statusCode == 200) {
        user.value = updatedUser;
        _showProfilePageSnackbar('Success', 'Profile updated successfully');

        // Ensure that the profile page is reloaded with the new data
        await fetchUserProfile();

        // Navigate back to the ProfilePage upon successful update
        Get.off(() => const ProfilePage());
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
  void refreshAvatar() {
    String newAvatar = multiavatar(user.value.avatarID ?? 'User');
    // Update user model with the new avatar
    user.update((val) {
      val?.avatarID = newAvatar;
    });
    // Notify listeners about the update
    update();
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
    // Update user model with the new picture path
    user.update((val) {
      val?.avatarID = path;
    });
    // Notify listeners about the update
    update();
  }

  // Method to clear the profile picture
  void clearProfilePicture() {
    profilePicturePath.value = '';
    // Revert back to generated avatar
    String defaultAvatar = multiavatar(user.value.fullName ?? 'User');
    user.update((val) {
      val?.avatarID = defaultAvatar;
    });
    // Notify listeners about the update
    update();
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
