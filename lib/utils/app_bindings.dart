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
    Get.put(CartController(), permanent: true);
    Get.put(ProductRepo(), permanent: true);
    Get.putAsync<SharedPreferences>(() async {
      final sharedPreferences = await SharedPreferences.getInstance();
      Get.put(
          ApiClient(
            appBaseUrl: AppConstants.BASE_URL,
            appBaseUrlProduct: AppConstants.BASE_URL_PRODUCT,
            sharedPreferences: sharedPreferences,
          ),
          permanent: true);
      Get.put(AuthRepo(sharedPreferences: sharedPreferences), permanent: true);
      Get.put(AuthController(authRepo: Get.find<AuthRepo>()), permanent: true);
      Get.put(ProductController(productRepo: Get.find<ProductRepo>()),
          permanent: true);
      return sharedPreferences;
    }, permanent: true);
  }
}
