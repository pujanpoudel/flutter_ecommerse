import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../repo/auth_repo.dart';
import '../../utils/colors.dart';

class EditEmailPage extends StatefulWidget {
  const EditEmailPage({super.key});

  @override
  _EditEmailPageState createState() => _EditEmailPageState();
}

class _EditEmailPageState extends State<EditEmailPage> {
  late String currentEmail;
  final TextEditingController _newEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentEmail = Get.find<AuthRepo>().getUserEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 100),
              child: const Text(
                'Edit Email',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Current email: $currentEmail',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 30),
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
                      'New Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: TextField(
                      controller: _newEmailController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your new email',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                height: 50,
                width: 250,
                child: ElevatedButton(
                  onPressed: _updateEmail,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.mainColor,
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text('Update Email'),
                ),
              ),
            ),
const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                  Get.back(); // Go back to the previous page
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.cancel,
                      size: 30,
                      color: AppColors.mainColor,
                    )
                  ],
                ),
              ),
            ),
           ],
        ),
      ),
    );
  }

  void _updateEmail() async {
    // Implement email update logic here
    // For example:
    // 1. Validate the new email
    // 2. Send a request to your server to update the email
    // 3. If successful, update the email in SharedPreferences
    String newEmail = _newEmailController.text.trim();
    if (newEmail.isNotEmpty && GetUtils.isEmail(newEmail)) {
      // Assuming you have an updateEmail method in your AuthRepo
      // Response response = await Get.find<AuthRepo>().updateEmail(newEmail);
      // if (response.isOk) {
      //   await Get.find<AuthRepo>().saveUserEmail(newEmail);
      //   Get.back();
      // } else {
      //   // Show error message
      // }
    } else {
      // Show error message for invalid email
    }
  }
}