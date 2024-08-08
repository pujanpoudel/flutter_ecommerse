import 'package:get/get.dart';
import 'package:quick_cart/controller/product_controller.dart';
import 'package:quick_cart/repo/product_repo.dart';
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
      Get.lazyPut(() => AuthRepo(sharedPreferences: Get.find()));
      Get.lazyPut(() => AuthController(
          authRepo: Get.find<AuthRepo>()));
      Get.lazyPut(() => ProductRepo());
    Get.lazyPut(() => ProductController(productRepo: Get.find<ProductRepo>()));
    });
  }
}
