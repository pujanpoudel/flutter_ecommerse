import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multiavatar/multiavatar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quick_cart/controller/auth_controller.dart';
import '../../utils/colors.dart';


class EditProfilePage extends StatelessWidget {
  final AuthController controller = Get.find<AuthController>();

  EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Edit Profile',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
      ),
      body: Obx(() => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileHeader(),
                _buildEditForm(),
                _buildActionButtons(),
              ],
            ),
          )),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: AppColors.mainColor,
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => controller.pickProfilePicture(),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: controller.profilePicturePath.value.isNotEmpty
                      ? ClipOval(
                          child: Image.file(
                            File(controller.profilePicturePath.value),
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                          ),
                        )
                      : SvgPicture.string(
                          multiavatar(controller.user.value.fullName ?? 'User'),
                          width: 120,
                          height: 120,
                        ),
                ),
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: Icon(Icons.camera_alt,
                      color: AppColors.mainColor, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildInputField(Icons.person, 'Full Name', 'Enter your full name',
              controller.fullNameController),
          _buildInputField(Icons.email, 'Email', 'Enter your email',
              controller.emailController),
          _buildInputField(Icons.phone, 'Phone Number',
              'Enter your phone number', controller.phoneNumberController),
        ],
      ),
    );
  }

  Widget _buildInputField(IconData icon, String label, String hint,
      TextEditingController textController) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: textController,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.mainColor),
          labelText: label,
          hintText: hint,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            width: 200, // Make button take full width of the container
            child: ElevatedButton.icon(
              onPressed: () => controller.updateProfile(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('Save Changes'),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: 200, // Make button take full width of the container
            child: OutlinedButton.icon(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.mainColor,
                side: const BorderSide(color: AppColors.mainColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.cancel, color: AppColors.mainColor),
              label: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }
}
