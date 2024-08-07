import 'package:get/get.dart';
import 'package:quick_cart/controller/product_controller.dart';
import 'package:quick_cart/controller/user_controller.dart';
import 'package:quick_cart/repo/product_repo.dart';
import 'package:quick_cart/repo/user_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/auth_controller.dart';
import '../repo/auth_repo.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.putAsync<SharedPreferences>(() async {
      final sharedPreferences = await SharedPreferences.getInstance();
      return sharedPreferences;
    }).then((sharedPreferences) {
      // Initialize dependencies that require SharedPreferences after it is ready
      Get.lazyPut(() => AuthRepo(sharedPreferences: sharedPreferences));
      Get.lazyPut(() => UserRepo());
      Get.lazyPut(() => AuthController(
          authRepo: Get.find<AuthRepo>(),
          userRepo: Get.find<UserRepo>()));
      Get.lazyPut(() => ProductRepo());
      Get.lazyPut(() => ProductController(productRepo: Get.find<ProductRepo>()));
      Get.lazyPut(() => UserController(userRepo: Get.find(), authRepo: Get.find()));
    });
  }
}
