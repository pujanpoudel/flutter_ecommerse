import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quick_cart/controller/product_controller.dart';
import 'package:quick_cart/utils/bottom_nav_bar_widget.dart';
import 'package:quick_cart/utils/skeleton_loader_widget.dart';
import '../../utils/colors.dart';

class HomePage extends StatelessWidget {
  final ProductController productController = Get.find<ProductController>();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 0,
      body: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.mainColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              SvgPicture.asset(
                'assets/delivery_icon.svg',
                width: 100,
                height: 70,
              ),
              const SizedBox(width: 5),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Delivery address', style: TextStyle(fontSize: 14)),
                  Row(
                    children: [
                      Text(' Khairahani, Chitwan',
                          style: TextStyle(fontSize: 15)),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () {}),
            IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: productController.refreshProducts,
          child: Obx(() {
            if (productController.isLoading.value &&
                productController.products.isEmpty) {
              return _buildSkeletonLoader();
            } else if (productController.errorMessage.isNotEmpty) {
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
      ),
    );
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
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification &&
            scrollNotification.metrics.extentAfter == 0 &&
            !productController.isLoading.value &&
            productController.currentPage.value <
                productController.totalPages.value) {
          productController.loadMoreProducts();
        }
        return false;
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildProductList(),
            if (productController.isLoading.value &&
                productController.products.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
      ),
      itemCount: productController.products.length,
      itemBuilder: (context, index) {
        final product = productController.products[index];
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.network(
                  product.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${product.price}',
                      style: const TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
