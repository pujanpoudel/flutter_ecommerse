import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quick_cart/models/user_model.dart';
import 'package:quick_cart/repo/user_repo.dart';
import '../repo/auth_repo.dart';
import '../view/auth/forgot_password_page.dart';
import '../view/auth/sign_in_page.dart';
import '../view/auth/sign_up_page.dart';
import '../view/product/home_page.dart';
import '../view/verification/email_verification_page.dart';

class AuthController extends GetxController {
  final AuthRepo authRepo;
  final UserRepo userRepo;

  var user = UserModel().obs;
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

  AuthController({required this.authRepo, required this.userRepo});

  @override
  void onInit() {
    super.onInit();
    checkRememberMe();
    fetchUserProfile();
    loadProfilePicture();
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
      final response = await authRepo.signUp(
        fullNameController.text,
        emailController.text,
        passwordController.text,
        confirmPasswordController.text,
        phoneNumberController.text,
        addressController.text,
      );
      isLoading.value = false;

      print('SignUp Response code: ${response.statusCode}');
      print('SignUp Response body: ${response.body}');

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
      print('SignUp Error: $e');
      Get.snackbar('Error', 'Failed to sign up. Please try again.');
    }
  }

  Future<void> pickProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      profilePicturePath.value = pickedFile.path;
      await authRepo.saveProfilePicture(pickedFile.path);
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      String token = authRepo.getUserToken();
      final response = await userRepo.getUserProfile(token);
      if (response.statusCode == 200) {
        user.value = UserModel.fromJson(response.body['data']);
        fullNameController.text = user.value.fullName ?? '';
        emailController.text = user.value.email ?? '';
        phoneNumberController.text = user.value.phone ?? '';
      } else {
        Get.snackbar('Error', 'Failed to load user profile');
      }
    } catch (e) {
      print('FetchUserProfile Error: $e');
      Get.snackbar('Error', 'Failed to load user profile');
    }
  }

  Future<void> updateProfile() async {
    try {
      String token = authRepo.getUserToken();
      UserModel updatedUser = user.value.copyWith(
        fullName: fullNameController.text,
        email: emailController.text,
        phone: phoneNumberController.text,
      );
      final response = await userRepo.updateUserProfile(updatedUser, token);
      if (response.statusCode == 200) {
        user.value = updatedUser;
        Get.snackbar('Success', 'Profile updated successfully');
      } else {
        Get.snackbar('Error', 'Failed to update profile');
      }
    } catch (e) {
      print('UpdateProfile Error: $e');
      Get.snackbar('Error', 'Failed to update profile');
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

      print('SignIn Response code: ${response.statusCode}');
      print('SignIn Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = response.body['data'];

        // Safely access the tokens and handle potential null values
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
      print('SignIn Error: $e');
      Get.snackbar('Error', 'Failed to sign in. Please try again.');
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
    Get.to(
      () => SignUpPage(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void navigateToSignIn() {
    Get.to(() => SignInPage());
  }

  void navigateToHomePage() {
    Get.to(
      () => HomePage(),
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
    try {
      await authRepo.saveUserEmail(newEmail);
      emailController.text = newEmail;
      isLoading.value = false;
      Get.snackbar('Success', 'Email updated successfully');
    } catch (e) {
      isLoading.value = false;
      print('Update email error: $e');
      Get.snackbar('Error', 'Failed to update email. Please try again.');
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
