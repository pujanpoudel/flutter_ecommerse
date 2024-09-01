import 'package:get/get.dart';
import 'package:quick_cart/api/api_client.dart';
import 'package:quick_cart/controller/product_controller.dart';
import 'package:quick_cart/repo/product_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/auth_controller.dart';
import '../repo/auth_repo.dart';
import '../utils/app_constants.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.putAsync<SharedPreferences>(() async {
      final sharedPreferences = await SharedPreferences.getInstance();
      return sharedPreferences;
    }).then((sharedPreferences) {
      // Initialize ApiClient
      Get.lazyPut(() => ApiClient(
            appBaseUrl: AppConstants.BASE_URL,
            appBaseUrlProduct:AppConstants.BASE_URL_PRODUCT,
            sharedPreferences: sharedPreferences,
          ));

      // Initialize repositories
      Get.lazyPut(() => AuthRepo(sharedPreferences: sharedPreferences));
      Get.lazyPut(() => ProductRepo());

      // Initialize controllers
      Get.lazyPut(() => AuthController(authRepo: Get.find<AuthRepo>()));
      Get.lazyPut(
          () => ProductController(productRepo: Get.find<ProductRepo>()));
    });
  }
}
