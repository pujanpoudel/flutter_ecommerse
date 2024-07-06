import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/routes/route_helper.dart';
import 'package:flutter_ecommerce/view/splash%20screen/splash_screen.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/login_binding.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await initServices();
//   runApp(const MyApp());
// }

// Future<void> initServices() async {
//   final sharedPreferences = await SharedPreferences.getInstance();
//   Get.lazyPut(() => sharedPreferences);
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Quick Cart',
//       initialRoute: RouteHelper.initial,
//       initialBinding: LoginBinding(),
//     );
//   }
// }

void main() {
  runApp(SplashScreen());
}
