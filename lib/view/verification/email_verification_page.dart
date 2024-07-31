import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../repo/auth_repo.dart';
import '../../utils/colors.dart';
import 'otp_verification_page.dart';

class EmailVerificationPage extends StatelessWidget {
  const EmailVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.mainColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Verify your Email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Check your email & click the link to activate your account',
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 16,
                ),
              ),
              Center(
                child: Image.asset(
                  'assets/new-email.png',
                  fit: BoxFit.contain,
                  height: 500, // Adjust as needed
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final AuthRepo authRepo =
                      Get.find<AuthRepo>(); // Get the AuthRepo instance
                  final String email =
                      authRepo.getUserEmail(); // Get the user's email

                  // First, try to launch the default mail app
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: email,
                  );

                  try {
                    if (await canLaunchUrl(emailLaunchUri)) {
                      await launchUrl(emailLaunchUri);
                    } else {
                      // If the mail app can't be launched, try opening Gmail in the browser
                      final Uri gmailInBrowserUri =
                          Uri.parse('https://mail.google.com/');
                      if (await canLaunchUrl(gmailInBrowserUri)) {
                        await launchUrl(gmailInBrowserUri,
                            mode: LaunchMode.externalApplication);
                      } else {
                        // If Gmail can't be opened in the browser, show an error message
                        Get.snackbar('Error',
                            'Unable to open email application or Gmail');
                      }
                    }
                  } catch (e) {
                    // If any error occurs during the process, show a generic error message
                    Get.snackbar('Error',
                        'An error occurred while trying to open email: $e');
                  }

                  // Navigate to OTP verification page after attempting to open email
                  Get.to(() => OTPVerificationPage());
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.whiteColor,
                  backgroundColor: AppColors.mainColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Go to Inbox",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Implement resend email logic
                  },
                  child: const Text(
                    "Resend Email",
                    style: TextStyle(
                      color: AppColors.mainColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
