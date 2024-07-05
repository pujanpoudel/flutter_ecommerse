import 'package:ecommerse_demo/routes/app_routes.dart';
import 'package:ecommerse_demo/view/dashboard_page.dart';
import 'package:get/route_manager.dart';

class AppPages {
  static var list= [
    GetPage(name: AppRoutes.dashboard, page: ()=> const DashboardPage())
  ];
}