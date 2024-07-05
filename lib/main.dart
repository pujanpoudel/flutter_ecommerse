import 'package:ecommerse_demo/routes/app_pages.dart';
import 'package:ecommerse_demo/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: AppPages.list,
      initialRoute: AppRoutes.dashboard,
      debugShowCheckedModeBanner: false,
    );
  }
}
