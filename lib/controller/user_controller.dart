import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quick_cart/controller/auth_controller.dart';
import 'package:quick_cart/models/user_model.dart';
import 'package:quick_cart/repo/auth_repo.dart';
import 'package:quick_cart/repo/user_repo.dart';

class UserController extends GetxController {
  final UserRepo userRepo;
  final AuthRepo authRepo;
  final AuthController authController = Get.find<AuthController>();

  var user = UserModel().obs;
  var isLoading = false.obs;
  var profilePicturePath = ''.obs;
  var isProfilePageVisible = false.obs;

  UserController({required this.userRepo, required this.authRepo});

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    isLoading(true);
    try {
      String token = authRepo.getUserToken();
      final response = await userRepo.getUserProfile(token);
      if (response.statusCode == 200) {
        user.value = UserModel.fromJson(response.body['data']);
      } else {
        showProfilePageSnackbar('Error', 'Failed to load user profile');
      }
    } catch (e) {
      print('FetchUserProfile Error: $e');
      showProfilePageSnackbar('Error', 'Failed to load user profile');
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateUserProfile({
    String? fullName,
    String? email,
    String? phone,
  }) async {
    isLoading(true);
    try {
      String token = authRepo.getUserToken();
      UserModel updatedUser = user.value.copyWith(
        fullName: fullName ?? user.value.fullName,
        email: email ?? user.value.email,
        phone: phone ?? user.value.phone,
      );
      final response = await userRepo.updateUserProfile(updatedUser, token);
      if (response.statusCode == 200) {
        user.value = updatedUser;
        showProfilePageSnackbar('Success', 'Profile updated successfully');
      } else {
        showProfilePageSnackbar('Error', 'Failed to update profile');
      }
    } catch (e) {
      print('UpdateUserProfile Error: $e');
      showProfilePageSnackbar('Error', 'Failed to update profile');
    } finally {
      isLoading(false);
    }
  }

  String get fullName => user.value.fullName ?? '';
  String get email => user.value.email ?? '';
  String get phone => user.value.phone ?? '';

  Future<void> pickProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        profilePicturePath.value = pickedFile.path;
      }
    } catch (e) {
      print('PickProfilePicture Error: $e');
      showProfilePageSnackbar('Error', 'Failed to pick profile picture');
    }
  }

  void showProfilePageSnackbar(String title, String message) {
    if (isProfilePageVisible.value) {
      Get.snackbar(title, message);
    }
  }
}
