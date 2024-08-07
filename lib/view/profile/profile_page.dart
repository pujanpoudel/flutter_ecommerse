import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multiavatar/multiavatar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quick_cart/controller/auth_controller.dart';
import '../../controller/user_controller.dart';
import '../../utils/colors.dart';
import 'edit_profile_page.dart';

class ProfilePage extends GetView<UserController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController controller = Get.find<UserController>();
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(),
                  _buildProfileInfo(),
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
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            child: _buildAvatarContent(),
          ),
          const SizedBox(height: 15),
          Text(
            controller.fullName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            controller.email,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
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
          _buildInfoItem(Icons.person, 'Full Name', controller.fullName),
          _buildInfoItem(Icons.email, 'Email', controller.email),
          _buildInfoItem(Icons.phone, 'Phone', controller.phone),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.mainColor),
        title: Text(label,
            style: const TextStyle(fontSize: 14, color: Colors.grey)),
        subtitle: Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildAvatarContent() {
    final AuthController authController = Get.find<AuthController>();
    return Obx(() {
      if (authController.profilePicturePath.value.isNotEmpty) {
        return ClipOval(
          child: Image.file(
            File(authController.profilePicturePath.value),
            fit: BoxFit.cover,
            width: 120,
            height: 120,
          ),
        );
      } else {
        try {
          String svgString =
              multiavatar(authController.user.value.fullName ?? 'User');
          return SvgPicture.string(
            svgString,
            width: 120,
            height: 120,
          );
        } catch (e) {
          print('Error generating avatar: $e');
          return Text(
            authController.user.value.fullName != null &&
                    authController.user.value.fullName!.isNotEmpty
                ? authController.user.value.fullName![0].toUpperCase()
                : '?',
            style: const TextStyle(fontSize: 40, color: AppColors.mainColor),
          );
        }
      }
    });
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.find<AuthController>().signOut(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Log Out'),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Get.to(() => EditProfilePage()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Edit Profile'),
            ),
          ),
        ],
      ),
    );
  }
}
