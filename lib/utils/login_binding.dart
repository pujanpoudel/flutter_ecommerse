import 'package:get/get.dart';

import '../controller/login_controller.dart';
import '../repo/login_repo.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginRepo(sharedPreferences: Get.find()));
    Get.lazyPut(() => LoginController(loginRepo: Get.find()));
  }
}