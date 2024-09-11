import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quick_cart/controller/product_controller.dart';
import 'package:quick_cart/models/product_model.dart';
import 'package:quick_cart/utils/colors.dart';

class ProductDetailPage extends StatelessWidget {
  final String productId;
  final ProductController productController = Get.find<ProductController>();

  ProductDetailPage(
      {super.key, required this.productId, required Product product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Product?>(
        future: productController.getProductById(productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.horizontalRotatingDots(
                color: AppColors.mainColor,
                size: 20,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Product not found'));
          }

          final product = snapshot.data!;
          return CustomScrollView(
            slivers: [
              _buildAppBar(product),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductImage(product),
                    _buildProductInfo(product),
                    SizedBox(height: 250),
                    //_buildColorAndSizeOptions(product),
                    _buildActionButtons(product),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(Product product) {
    return SliverAppBar(
      expandedHeight: 60,
      floating: true,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
          onPressed: () {
            // TODO: Implement cart navigation
          },
        ),
      ],
    );
  }

  Widget _buildProductImage(Product product) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          Image.network(
            product.image,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: LoadingAnimationWidget.horizontalRotatingDots(
                  color: AppColors.mainColor,
                  size: 20,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo(Product product) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            Obx(() => IconButton(
              icon: Icon(
                productController.isFavorite(product.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: productController.isFavorite(product.id)
                    ? Colors.red
                    : Colors.grey[600],
              ),
              onPressed: () {
                productController.toggleFavorite(product.id);
              },
            )),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'From: ${product.vendor.storeName}',
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.mainBlackColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'NRP ${product.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 20,
                color: AppColors.mainColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.mainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Free shipping',
                style: TextStyle(
                  color: AppColors.mainColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          product.description,
          style: const TextStyle(fontSize: 16, color: AppColors.textColor),
        ),
      ],
    ),
  );
}

  Widget _buildColorAndSizeOptions(Product product) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Colors',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        //_buildColorOptions(product.color),
        const SizedBox(height: 16),
        const Text(
          'Sizes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildSizeOptions(product.size),
      ],
    ),
  );
}

Widget _buildColorOptions(List<Color> colors) {
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: colors.map((color) => _buildColorOption(color)).toList(),
  );
}

Widget _buildColorOption(Color color) {
  return Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      //color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.grey),
    ),
  );
}

Widget _buildSizeOptions(List<String> sizes) {
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: sizes.map((size) => _buildSizeOption(size)).toList(),
  );
}

Widget _buildSizeOption(String size) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(size),
  );
}

  Widget _buildActionButtons(Product product) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement add to cart functionality
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add to Cart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement buy now functionality
              },
              icon: const Icon(Icons.shopping_bag),
              label: const Text('Buy Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.mainColor,
                side: const BorderSide(color: AppColors.mainColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
