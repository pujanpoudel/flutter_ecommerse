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
    Get.putAsync(() async {
      final sharedPreferences = await SharedPreferences.getInstance();
      return sharedPreferences;
    });

    Get.lazyPut(() => ApiClient(
          appBaseUrl: AppConstants.BASE_URL,
          appBaseUrlProduct: AppConstants.BASE_URL_PRODUCT,
          sharedPreferences: Get.find<SharedPreferences>(),
        ));

    Get.lazyPut(
        () => AuthRepo(sharedPreferences: Get.find<SharedPreferences>()));
    Get.lazyPut(() => ProductRepo());

    Get.lazyPut(() => AuthController(authRepo: Get.find<AuthRepo>()));
    Get.put(CartController());

    Get.lazyPut(() => ProductController(productRepo: Get.find<ProductRepo>()));
  }
}
