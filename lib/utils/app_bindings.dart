import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/auth_controller.dart';
import '../repo/auth_repo.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() async {

    // Initialize SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    
    // Register SharedPreferences with GetX
    Get.put<SharedPreferences>(sharedPreferences);

    // Register other dependencies
    Get.put(AuthRepo(sharedPreferences: Get.find()));
    Get.put(AuthController(authRepo: Get.find()));
  }
}
