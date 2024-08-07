import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:quick_cart/controller/product_controller.dart';
import 'package:quick_cart/controller/user_controller.dart';
import 'package:quick_cart/models/product_model.dart';
import 'package:quick_cart/utils/bottom_nav_bar_widget.dart';
import 'package:quick_cart/utils/skeleton_loader_widget.dart';
import '../../utils/colors.dart';
import 'product_detail_page.dart';

class HomePage extends StatelessWidget {
  final ProductController productController = Get.find<ProductController>();
  final UserController userController = Get.find<UserController>();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
        currentIndex: 0,
        body: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.creamColor,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delivery address',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                Row(
                  children: [
                    Text(' Khairahani, Chitwan',
                        style: TextStyle(fontSize: 14)),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                  icon: const Icon(Icons.shopping_cart), onPressed: () {}),
              IconButton(
                  icon: const Icon(Icons.notifications), onPressed: () {}),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: productController.fetchProducts,
            child: Obx(() {
              if (productController.isLoading.value) {
                return _buildSkeletonLoader();
              } else if (productController.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(productController.errorMessage.value),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: productController.fetchProducts,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              } else {
                return _buildContent();
              }
            }),
          ),
        ));
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SkeletonLoader(
              height: 50,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SkeletonLoader(
            height: 180,
            borderRadius: BorderRadius.circular(10),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SkeletonLoader(
              width: 100,
              height: 20,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SkeletonLoader(
                    width: 80,
                    height: 80,
                    borderRadius: BorderRadius.circular(40),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLoader(
                  width: 150,
                  height: 20,
                  borderRadius: BorderRadius.circular(5),
                ),
                SkeletonLoader(
                  width: 80,
                  height: 20,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SkeletonLoader(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonLoader(
                            width: 100,
                            height: 20,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          const SizedBox(height: 5),
                          SkeletonLoader(
                            width: 80,
                            height: 20,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          const SizedBox(height: 5),
                          SkeletonLoader(
                            height: 30,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search here...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          CarouselSlider(
            options: CarouselOptions(
              height: 180.0,
              enlargeCenterPage: true,
              autoPlay: true,
            ),
            items: [1, 2, 3, 4, 5].map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      color: i == 1 ? Colors.orange : Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/apple.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Category',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryItem(Icons.shopping_bag, 'Apparel'),
                _buildCategoryItem(Icons.school, 'School'),
                _buildCategoryItem(Icons.sports_soccer, 'Sports'),
                _buildCategoryItem(Icons.devices, 'Electronic'),
                _buildCategoryItem(Icons.grid_view, 'All'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent products',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: const Text('Filters')),
              ],
            ),
          ),
          _buildProductGrid(),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label) {
    return SizedBox(
      width: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 5),
          Text(label, style: GoogleFonts.poppins(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
      ),
      itemCount: productController.products.length,
      itemBuilder: (context, index) {
        final Product product = productController.products[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(product: product),
              ),
            );
          },
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    color: AppColors.creamColor,
                    child: Center(
                      child: Image.network(
                        product.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${product.price}',
                        style: GoogleFonts.poppins(color: Colors.green),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Add to cart'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
