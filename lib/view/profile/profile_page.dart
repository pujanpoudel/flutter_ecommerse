import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:multiavatar/multiavatar.dart';
import 'package:quick_cart/controller/auth_controller.dart';
import 'package:quick_cart/controller/user_controller.dart';
import 'package:quick_cart/utils/bottom_nav_bar_widget.dart';
import 'package:quick_cart/utils/colors.dart';
import 'package:quick_cart/view/profile/edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  final UserController userController = Get.find<UserController>();

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    userController.isProfilePageVisible.value = true;

    return MainLayout(
      currentIndex: 3,
      body: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          backgroundColor: AppColors.mainColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              userController.isProfilePageVisible.value = false;
              Get.back();
            },
          ),
          title: const Text(
            'My Profile',
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        body: Obx(() => userController.isLoading.value
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
      ),
    );
  }

  Widget _buildProfileHeader() {
    final UserController controller = Get.find<UserController>();
    return Container(
      color: AppColors.mainColor,
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            child: SvgPicture.string(
              multiavatar(controller.user.value.fullName ?? 'User'),
              width: 120,
              height: 120,
            ),
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
          _buildInfoItem(Icons.person, 'Full Name', userController.fullName),
          _buildInfoItem(Icons.email, 'Email', userController.email),
          _buildInfoItem(Icons.phone, 'Phone', userController.phone),
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

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: () {
                userController.isProfilePageVisible.value = false;
                Get.to(() => EditProfilePage());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text('Edit Profile'),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: 200,
            child: OutlinedButton.icon(
              onPressed: () {
                userController.isProfilePageVisible.value = false;
                Get.find<AuthController>().signOut();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }
}
