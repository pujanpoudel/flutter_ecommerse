import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../product/home_page.dart';

class ChangePasswordController extends GetxController {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final RxBool obscureNewPassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool isLoading = false.obs;

  void toggleNewPasswordVisibility() => obscureNewPassword.toggle();
  void toggleConfirmPasswordVisibility() => obscureConfirmPassword.toggle();

  void changePassword() {
    // Implement password change logic here
    isLoading.value = true;
    // Simulating API call
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      Get.snackbar('Success', 'Password changed successfully');
    });
  }
}

class ChangePasswordPage extends StatelessWidget {
  final ChangePasswordController controller = Get.put(ChangePasswordController());

  ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.mainBlackColor),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: AppColors.mainBlackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Obx(() => _buildPasswordField(
                  'New Password',
                  'Enter your new password',
                  controller.newPasswordController,
                  controller.obscureNewPassword.value,
                  controller.toggleNewPasswordVisibility,
                )),
                const SizedBox(height: 20),
                Obx(() => _buildPasswordField(
                  'Confirm Password',
                  'Confirm your new password',
                  controller.confirmPasswordController,
                  controller.obscureConfirmPassword.value,
                  controller.toggleConfirmPasswordVisibility,
                )),
                const SizedBox(height: 40),
                Center(
  child: SizedBox(
    height: 50,
    width: 250,
    child: Obx(() => ElevatedButton(
      onPressed: controller.isLoading.value
          ? null
          : () async {
              try {
                controller.changePassword();
                // If changePassword is successful, navigate to HomePage
                Get.offAll(() => HomePage());
              } catch (e) {
                // Handle any errors that occur during password change
                Get.snackbar('Error', 'Failed to change password: $e');
              }
            },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.mainColor,
        textStyle: const TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      child: controller.isLoading.value
          ? const CircularProgressIndicator(
              color: Colors.white,
            )
          : const Text('Change Password'),
    )),
  ),
),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
      String label,
      String hint,
      TextEditingController controller,
      bool obscureText,
      VoidCallback toggleObscureText) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.creamColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: toggleObscureText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}