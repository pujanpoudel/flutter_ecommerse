import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_cart/utils/colors.dart';
import 'package:quick_cart/view/product/home_page.dart';
import 'package:quick_cart/view/profile/profile_page.dart';

class MainLayout extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final bool isNavBarVisible; // Add this to control visibility

  const MainLayout({
    super.key,
    required this.body,
    required this.currentIndex,
    this.isNavBarVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removed the app bar
      body: body,
      bottomNavigationBar: isNavBarVisible
          ? BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) {
                if (index == 0) {
                  Get.to(() => HomePage());
                }
                if (index == 1) {
                  // Get.to(() => SearchPage());
                }
                if (index == 2) {
                  // Get.to(() => CartHistoryPage());
                }
                if (index == 3) {
                  //   Get.to(() => FavPage());
                }
                if (index == 4) {
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
                  icon: Icon(Icons.history),
                  label: 'Cart',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'Fav',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              backgroundColor: AppColors.whiteColor,
              selectedItemColor: AppColors.mainColor,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: false,
            )
          : null, // Hide the navigation bar when not visible
    );
  }
}
