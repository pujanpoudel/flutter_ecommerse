import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_cart/view/product/home_page.dart';
import '../../utils/colors.dart';

class EmailVerifiedPage extends StatelessWidget {
  const EmailVerifiedPage({super.key});

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
          'Email Verified',
          style: TextStyle(
            color: AppColors.mainBlackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Image.asset(
                  'assets/email-verified.png', // Make sure to add this image to your assets
                  fit: BoxFit.contain,
                  height: 400,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Email Verified Successfully!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mainBlackColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Your email has been verified. You can now staer exploring products to the fullest.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                  Get.to(() => HomePage());
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.mainColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 55),
                  elevation: 5,
                ),
                child: const Text(
                  "Start Shopping",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
