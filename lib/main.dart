import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'routes/route_helper.dart';
import 'utils/app_bindings.dart'; // Adjust the import path accordingly

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Quick Cart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialBinding: AppBinding(), // Set initial bindings
      initialRoute: RouteHelper.getInitial(), // Set initial route
      getPages: RouteHelper.routes, // Set up routes
    );
  }
}
