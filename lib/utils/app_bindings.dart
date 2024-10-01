import 'package:get/get.dart';
import 'package:quick_cart/api/api_client.dart';
import 'package:quick_cart/controller/cart_controller.dart';
import 'package:quick_cart/controller/product_controller.dart';
import 'package:quick_cart/repo/product_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/auth_controller.dart';
import '../repo/auth_repo.dart';
import '../utils/app_constants.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CartController(), permanent: true);

    print("AppBinding dependencies called");
    Get.put(CartController(), permanent: true);
    print("CartController put in GetX container");
    Get.putAsync<SharedPreferences>(() async {
      final sharedPreferences = await SharedPreferences.getInstance();
      return sharedPreferences;
    }).then((sharedPreferences) {
      Get.put(ApiClient(
        appBaseUrl: AppConstants.BASE_URL,
        appBaseUrlProduct: AppConstants.BASE_URL_PRODUCT,
        sharedPreferences: sharedPreferences,
      ));

      Get.put(AuthRepo(sharedPreferences: sharedPreferences));
      Get.put(ProductRepo());

      Get.put(AuthController(authRepo: Get.find<AuthRepo>()));
      Get.put(ProductController(productRepo: Get.find<ProductRepo>()));
      Get.put(CartController());
    });
  }
}
