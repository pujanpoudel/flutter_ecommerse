import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_cart/controller/auth_controller.dart';
import '../../utils/colors.dart';
import 'sign_in_page.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                  top: 10.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 100),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Enter your email address to reset your password.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 50),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.creamColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: TextField(
                              controller: authController.emailController,
                              decoration: const InputDecoration(
                                hintText: 'Enter your email',
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                authController.updateEmail(value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 350),
                    Center(
                      child: SizedBox(
                        height: 50,
                        width: 200,
                        child: Obx(() => ElevatedButton(
                              onPressed: authController.isLoading.value
                                  ? null
                                  : () async {
                                      await authController.resetPassword();
                                    },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: AppColors.mainColor,
                                textStyle: const TextStyle(fontSize: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              child: authController.isLoading.value
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text('Reset Password'),
                            )),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        height: 50,
                        width: 200,
                        child: OutlinedButton.icon(
                          onPressed: _goBackToSignIn,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.mainColor,
                            side: const BorderSide(color: AppColors.mainColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(
                            Icons.arrow_circle_left,
                            color: AppColors.mainColor,
                          ),
                          label: const Text(
                            'Back to Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _goBackToSignIn() {
    Get.off(
      () => SignInPage(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}
