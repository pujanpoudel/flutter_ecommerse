import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quick_cart/search/search.dart';
import 'package:quick_cart/utils/colors.dart';
import 'package:quick_cart/view/cart/cart_page.dart';
import 'package:quick_cart/view/product/fav_product_page.dart';
import 'package:quick_cart/view/product/home_page.dart';
import 'package:quick_cart/view/profile/profile_page.dart';

class MainLayout extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final bool isNavBarVisible;

  const MainLayout({
    super.key,
    required this.body,
    required this.currentIndex,
    this.isNavBarVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: isNavBarVisible
          ? BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) {
                if (index == 0) {
                  HapticFeedback.heavyImpact();
                  Get.to(() => const HomePage());
                }
                if (index == 1) {
                  HapticFeedback.heavyImpact();

                  Get.to(() => SearchPage());
                }
                if (index == 2) {
                  HapticFeedback.heavyImpact();

                  Get.to(() => CartPage());
                }
                if (index == 3) {
                  HapticFeedback.heavyImpact();

                  Get.to(() => const FavoriteProductsPage());
                }
                if (index == 4) {
                  HapticFeedback.heavyImpact();

                  Get.to(() => const ProfilePage());
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
          : null,
    );
  }
}
