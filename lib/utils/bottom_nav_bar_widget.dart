import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_cart/utils/colors.dart';
import 'package:quick_cart/view/product/home_page.dart';
import 'package:quick_cart/view/profile/profile_page.dart';

class MainLayout extends StatelessWidget {
  final Widget body;
  final int currentIndex;

  const MainLayout({super.key, required this.body, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 0) {
            Get.to(() => HomePage());
          }
          if (index == 1) {
            // Get.to(() => SearchPage());
          }
          if (index == 2) {
            // Get.to(() => CartPage());
          }
          if (index == 3) {
            Get.to(() => ProfilePage());
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: AppColors.mainColor,
          ),
        ],
        backgroundColor: AppColors.whiteColor,
        selectedItemColor: AppColors.mainColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: false,
      ),
    );
  }
}