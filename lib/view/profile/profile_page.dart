import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:multiavatar/multiavatar.dart';
import 'package:quick_cart/controller/auth_controller.dart';
import 'package:quick_cart/utils/bottom_nav_bar_widget.dart';
import 'package:quick_cart/utils/colors.dart';
import 'package:quick_cart/view/profile/edit_profile_page.dart';
import 'package:quick_cart/repo/auth_repo.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthController authController = Get.find<AuthController>();
  final AuthRepo authRepo = Get.find<AuthRepo>();
  final ScrollController _scrollController = ScrollController();
  final bool _isNavBarVisible = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final token = authRepo.getUserToken();
    if (token.isNotEmpty) {
      try {
        final response = await authRepo.getUserProfile(token);
        if (response.statusCode == 200) {
          authController.updateProfile();
        } else {
          print('Failed to load user profile: ${response.statusText}');
        }
      } catch (e) {
        print('Error loading user profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 4,
      isNavBarVisible: _isNavBarVisible,
      body: Scaffold(
        backgroundColor: AppColors.creamColor,
        body: Obx(() => authController.isLoading.value
            ? Center(
                child: LoadingAnimationWidget.horizontalRotatingDots(
                    color: AppColors.mainColor, size: 50))
            : RefreshIndicator(
                onRefresh: _loadUserProfile,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      _buildProfileHeader(),
                      _buildProfileInfo(),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              )),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: AppColors.creamColor,
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20, top: 20),
                child: Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: SvgPicture.string(
                  multiavatar(authController.user.value.fullName ?? 'User'),
                  width: 120,
                  height: 120,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Obx(() {
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
            _buildInfoItem(Icons.person, 'Full Name',
                authController.user.value.fullName ?? 'No Name'),
            _buildInfoItem(Icons.email, 'Email',
                authController.user.value.email ?? 'No Email'),
            _buildInfoItem(Icons.phone, 'Phone',
                authController.user.value.phone ?? 'No Phone'),
            _buildInfoItem(Icons.map, 'Address',
                authController.user.value.address ?? 'No Address'),
          ],
        ),
      );
    });
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
                authController.isProfilePageVisible.value = false;
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
              onPressed: () async {
                authController.isProfilePageVisible.value = false;
                await authRepo.signOut(rememberMe: false);
                Get.offAllNamed('/login');
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
