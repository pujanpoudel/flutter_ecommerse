import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multiavatar/multiavatar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:quick_cart/controller/auth_controller.dart';
import '../../utils/colors.dart';

class EditProfilePage extends StatelessWidget {
  final AuthController controller = Get.find<AuthController>();

  EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamColor,
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
                fontSize: 30,
                fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            _buildProfileImage(),
            const SizedBox(height: 15),
            _buildFilePickerButton(controller),
            _buildEditForm(),
            _buildActionButtons(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Obx(() {
        return Stack(
          alignment: Alignment.center,
          children: [
            if (controller.profilePicturePath.value.isNotEmpty)
              ClipOval(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.mainBlackColor),
                  ),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: Image.file(
                      File(controller.profilePicturePath.value),
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        return _buildDefaultAvatar();
                      },
                    ),
                  ),
                ),
              )
            else
              _buildDefaultAvatar(),
            Positioned(
              bottom: 5,
              right: 5,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.mainColor,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: IconButton(
                  icon:
                      const Icon(Icons.refresh, color: Colors.white, size: 16),
                  onPressed: () {
                    controller.refreshAvatar();
                    Get.snackbar(
                        'Avatar Updated', 'New avatar has been generated.',
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.transparent,
                        colorText: Colors.white);
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            if (controller.profilePicturePath.value.isNotEmpty)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 14),
                    onPressed: () {
                      controller.clearProfilePicture();
                      Get.snackbar('Avatar Cleared', 'Avatar has been removed.',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.transparent,
                          colorText: Colors.white);
                    },
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildDefaultAvatar() {
    return Obx(() {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.white,
        child: SvgPicture.string(
          controller.user.value.fullName ??
              multiavatar(controller.user.value.fullName ?? 'User'),
          width: 120,
          height: 120,
        ),
      );
    });
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
          _buildInputField(Icons.map, 'Address', 'Enter your Address',
              controller.addressController),
        ],
      ),
    );
  }
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

Widget _buildActionButtons(controller) {
  return Container(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        SizedBox(
          width: 250,
          child: ElevatedButton.icon(
            onPressed: () {
              controller.updateProfile();
              Get.snackbar('Profile Updated', 'Your changes have been saved.',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.transparent,
                  colorText: Colors.white);
            },
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
        const SizedBox(height: 20),
        SizedBox(
          width: 250,
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

Widget _buildFilePickerButton(controller) {
  return Center(
    child: SizedBox(
      width: 200,
      child: OutlinedButton.icon(
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles();
          if (result != null) {
            controller.updateProfilePicture(result.files.single.path!);
            Get.snackbar('Avatar Updated', 'Profile picture has been updated.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.transparent,
                colorText: Colors.white);
          }
        },
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Upload Picture'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.mainColor,
          side: const BorderSide(color: AppColors.mainColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    ),
  );
}
