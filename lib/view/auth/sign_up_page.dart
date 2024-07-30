import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth_controller.dart';
import '../../utils/colors.dart';

class SignUpPage extends StatelessWidget {
  final AuthController controller =
      Get.put(AuthController(authRepo: Get.find()));
  final RxBool obscureTextPassword = true.obs;
  final RxBool obscureTextConfirmPassword = true.obs;

  SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInputField(
                    label: 'Full Name',
                    hint: 'Enter your Full Name',
                    controller: controller.fullNameController),
                const SizedBox(height: 8),
                _buildInputField(
                    label: 'Email',
                    hint: 'Enter your Email',
                    controller: controller.emailController),
                const SizedBox(height: 8),
                Obx(() => _buildPasswordField(
                    label: 'Set Password',
                    hint: 'Set a new password',
                    obscureText: obscureTextPassword.value,
                    controller: controller.passwordController,
                    toggleObscureText: () {
                      obscureTextPassword.value = !obscureTextPassword.value;
                    })),
                const SizedBox(height: 8),
                Obx(() => _buildPasswordField(
                    label: 'Confirm Password',
                    hint: 'Confirm your password',
                    obscureText: obscureTextConfirmPassword.value,
                    controller: controller.confirmPasswordController,
                    toggleObscureText: () {
                      obscureTextConfirmPassword.value =
                          !obscureTextConfirmPassword.value;
                    })),
                const SizedBox(height: 8),
                _buildInputField(
                    label: 'Phone Number',
                    hint: 'Enter your Phone Number',
                    controller: controller.phoneNumberController),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: controller.navigateToSignIn,
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_right_alt,
                              size: 40,
                              color: AppColors.mainColor,
                            ),
                          ],
                        )),
                  ],
                ),
                const SizedBox(height: 15),
                Center(
                  child: SizedBox(
                    height: 50,
                    width: 250,
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.navigateToVerifyEmail,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.mainColor,
                            textStyle: const TextStyle(fontSize: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text('Sign Up'),
                        )),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'or sign up with',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      imageUrl: 'assets/facebook.png',
                      onPressed: () {},
                    ),
                    const SizedBox(width: 50),
                    _buildSocialButton(
                      imageUrl: 'assets/google.png',
                      onPressed: () {},
                    ),
                    const SizedBox(width: 50),
                    _buildSocialButton(
                      imageUrl: 'assets/apple.png',
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
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
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required bool obscureText,
    required TextEditingController controller,
    required VoidCallback toggleObscureText,
  }) {
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

  Widget _buildSocialButton({
    required String imageUrl,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 50.0,
        height: 50.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
