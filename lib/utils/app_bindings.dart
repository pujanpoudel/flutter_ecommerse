import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/sign_in_controller.dart';
import '../repo/sign_in_repo.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() async {
    // Initialize SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    
    // Register SharedPreferences with GetX
    Get.put<SharedPreferences>(sharedPreferences);

    // Register other dependencies
    Get.put(SignInRepo(sharedPreferences: Get.find()));
    Get.put(SignInController(signInRepo: Get.find()));
  }
}
