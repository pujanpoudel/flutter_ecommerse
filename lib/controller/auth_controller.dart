import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multiavatar/multiavatar.dart';
import 'package:quick_cart/models/auth_model.dart';
import 'package:quick_cart/repo/auth_repo.dart';
import 'package:quick_cart/view/auth/forgot_password_page.dart';
import 'package:quick_cart/view/auth/sign_in_page.dart';
import 'package:quick_cart/view/auth/sign_up_page.dart';
import 'package:quick_cart/view/landing%20page/landing_page.dart';
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
    loadSavedAvatar();
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

  Future<void> loadUserProfile() async {
    final token = authRepo.getUserToken(); // Get the token
    if (token.isNotEmpty) {
      try {
        // Fetch user profile data from the authRepo
        final userProfile = await authRepo.getUserProfile(token);
        if (userProfile != null) {
          // Update the user data in the controller
          user.value = userProfile;
          fullNameController.text = userProfile.fullName ?? '';
          emailController.text = userProfile.email ?? '';
          phoneNumberController.text = userProfile.phone ?? '';
          addressController.text = userProfile.address ?? '';

          // Debugging logs
          print('User Full Name: ${userProfile.fullName}');
          print('User Email: ${userProfile.email}');
          print('User Phone: ${userProfile.phone}');
          print('User Address: ${userProfile.address}');
        } else {
          print('Failed to load user profile: No data returned');
        }
      } catch (e) {
        print('Error loading user profile: $e');
      }
    } else {
      print('User token is empty');
    }
  }

  void updateProfile() async {
    try {
      String fullName = fullNameController.text;
      String phone = phoneNumberController.text;
      String address = addressController.text;

      Response response = await authRepo.updateUserProfile(
        user.value,
        fullName: fullName,
        phone: phone,
        address: address,
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Profile Updated',
          'Your profile has been successfully updated',
        );
        Get.off(() => const ProfilePage());
      } else {
        Get.snackbar('Error', 'Failed to update profile');
      }
    } catch (e) {
      print('Error in updateProfile: $e');
      Get.snackbar('Error', 'Failed to update profile');
    }
  }

  void refreshAvatar() {
    String newAvatar = multiavatar(user.value.fullName ?? 'User');
    user.update((val) {
      val?.avatarId = newAvatar;
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

  Future<void> checkLoginStatus() async {
    bool isFirstRun = authRepo.isFirstRun();
    bool isLoggedIn = authRepo.isLoggedIn();

    if (isFirstRun) {
      await authRepo.setFirstRunComplete();
      Get.off(() => const LandingPage());
    } else if (isLoggedIn) {
      Get.off(() => const HomePage());
    } else {
      Get.off(() => SignInPage());
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
