import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_cart/view/profile/edit_profile_page.dart';
import '../../controller/auth_controller.dart';
import '../../utils/colors.dart';

class ProfilePage extends StatelessWidget {
  final AuthController controller = Get.find<AuthController>();

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.mainColor),
          onPressed: () => Get.back(),
        ),
        title: const Text('My Profile', style: TextStyle(color: Colors.black, fontSize: 24)),
      ),
      body: Obx(() => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => controller.pickProfilePicture(),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: controller.profilePicturePath.value.isNotEmpty
                      ? FileImage(File(controller.profilePicturePath.value))
                      : const AssetImage('assets/default_profile_picture.png') as ImageProvider,
                  child: controller.profilePicturePath.value.isEmpty
                      ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                controller.user.value.fullName ?? '',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                controller.user.value.email ?? '',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.to(() => EditProfilePage()),
                child: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildInfoItem('ID', controller.user.value.id ?? ''),
              _buildInfoItem('SSNIT NUMBER', controller.user.value.ssnitNumber ?? ''),
              _buildInfoItem('PHONE', controller.user.value.phoneNumber ?? ''),
              const SizedBox(height: 30),
              _buildActionButton('LOG OUT', Colors.orange, onPressed: controller.signOut),
            ],
          ),
        ),
      )),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, {VoidCallback? onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed ?? () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
