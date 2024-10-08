import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../controller/auth_controller.dart';
import '../../utils/colors.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthController controller =
      Get.put(AuthController(authRepo: Get.find()));

  final RxBool obscureTextPassword = true.obs;

  final RxBool obscureTextConfirmPassword = true.obs;

  final RxBool passwordsMatch = true.obs;

  void _checkPasswordsMatch() {
    passwordsMatch.value = controller.passwordController.text ==
        controller.confirmPasswordController.text;
  }

  @override
  void dispose() {
    controller.passwordController.removeListener(_checkPasswordsMatch);
    controller.confirmPasswordController.removeListener(_checkPasswordsMatch);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller.passwordController.addListener(_checkPasswordsMatch);
    controller.confirmPasswordController.addListener(_checkPasswordsMatch);
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
                  margin: const EdgeInsets.only(top: 10),
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
                const SizedBox(height: 5),
                _buildInputField(
                    label: 'Email',
                    hint: 'Enter your Email',
                    controller: controller.emailController),
                const SizedBox(height: 5),
                Obx(() => _buildPasswordField(
                    label: 'Set Password',
                    hint: 'Set a new password',
                    obscureText: obscureTextPassword.value,
                    controller: controller.passwordController,
                    toggleObscureText: () {
                      obscureTextPassword.value = !obscureTextPassword.value;
                    })),
                const SizedBox(height: 5),
                Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPasswordField(
                          label: 'Confirm Password',
                          hint: 'Confirm your password',
                          obscureText: obscureTextConfirmPassword.value,
                          controller: controller.confirmPasswordController,
                          toggleObscureText: () {
                            obscureTextConfirmPassword.value =
                                !obscureTextConfirmPassword.value;
                          },
                          hasError: !passwordsMatch.value,
                        ),
                        if (!passwordsMatch.value)
                          const Padding(
                            padding: EdgeInsets.only(left: 10, top: 5),
                            child: Text(
                              'Passwords do not match',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    )),
                const SizedBox(height: 5),
                _buildInputField(
                    label: 'Phone Number',
                    hint: 'Enter your Phone Number',
                    controller: controller.phoneNumberController),
                const SizedBox(height: 5),
                _buildInputField(
                    label: 'Address',
                    hint: 'Enter your Delivery Address',
                    controller: controller.addressController),
                const SizedBox(height: 15),
                Center(
                  child: SizedBox(
                    height: 50,
                    width: 200,
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () async {
                                  print('Sign Up button pressed');
                                  await controller.signUp();
                                },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.mainColor,
                            textStyle: const TextStyle(fontSize: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? LoadingAnimationWidget.waveDots(
                                  color: AppColors.whiteColor, size: 50)
                              : const Text('Sign Up'),
                        )),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
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
                    )
                  ],
                ),
                const SizedBox(height: 15),
                const Center(
                  child: Text(
                    'or sign up with',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      imageUrl: 'assets/facebook.png',
                      onPressed: () {},
                    ),
                    const SizedBox(width: 30),
                    _buildSocialButton(
                      imageUrl: 'assets/google.png',
                      onPressed: () {},
                    ),
                    const SizedBox(width: 30),
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
    bool hasError = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.creamColor,
        borderRadius: BorderRadius.circular(10),
        border: hasError ? Border.all(color: Colors.red, width: 2) : null,
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
