import 'package:get/get.dart';
import 'package:quick_cart/api/api_client.dart';
import 'package:quick_cart/controller/auth_controller.dart';
import 'package:quick_cart/controller/cart_controller.dart';
import 'package:quick_cart/controller/product_controller.dart';
import 'package:quick_cart/repo/auth_repo.dart';
import 'package:quick_cart/repo/product_repo.dart';
import 'package:quick_cart/utils/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize CartController immediately
    Get.put(CartController(), permanent: true);

    // Initialize ProductRepo (doesn't depend on SharedPreferences)
    Get.put(ProductRepo(), permanent: true);

    // Initialize SharedPreferences and dependent services
    Get.putAsync<SharedPreferences>(() async {
      final sharedPreferences = await SharedPreferences.getInstance();

      // Initialize ApiClient
      Get.put(
          ApiClient(
            appBaseUrl: AppConstants.BASE_URL,
            appBaseUrlProduct: AppConstants.BASE_URL_PRODUCT,
            sharedPreferences: sharedPreferences,
          ),
          permanent: true);

      // Initialize AuthRepo
      Get.put(AuthRepo(sharedPreferences: sharedPreferences), permanent: true);

      // Initialize AuthController
      Get.put(AuthController(authRepo: Get.find<AuthRepo>()), permanent: true);

      // Initialize ProductController
      Get.put(ProductController(productRepo: Get.find<ProductRepo>()),
          permanent: true);

      return sharedPreferences;
    }, permanent: true);
  }
}
