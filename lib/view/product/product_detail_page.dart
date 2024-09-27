import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quick_cart/controller/cart_controller.dart';
import 'package:quick_cart/controller/product_controller.dart';
import 'package:quick_cart/models/cart_model.dart';
import 'package:quick_cart/models/product_model.dart';
import 'package:quick_cart/utils/colors.dart';
import 'package:quick_cart/view/cart/cart_page.dart';

class ProductDetailPage extends StatelessWidget {
  final String productId;
  final ProductController productController = Get.find<ProductController>();
  final CartController cartController = Get.find<CartController>();

  ProductDetailPage({super.key, required this.productId, required Product product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<CartModel?>(
  future: productController.getProductAsCartModel(productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.horizontalRotatingDots(
                color: AppColors.mainColor,
                size: 50,
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
                    const SizedBox(height: 16),
                    if (product.color != null) _buildColorOptions(product),
                    if (product.size != null) _buildSizeOptions(product),
                    const SizedBox(height: 16),
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

  Widget _buildAppBar(CartModel product) {
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
            Get.to(const CartPage());
          },
        ),
      ],
    );
  }

  Widget _buildProductImage(CartModel product) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(
        product.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
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
    );
  }

  Widget _buildProductInfo(CartModel product) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'NRP ${product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              color: AppColors.mainColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Add more product details here if needed
        ],
      ),
    );
  }

  Widget _buildColorOptions(CartModel product) {
    // You'll need to implement this based on how you store color options
    // This is just a placeholder
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Text(
            'Color:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Chip(
            label: Text(product.color ?? 'N/A'),
            backgroundColor: Colors.grey[200],
          ),
        ],
      ),
    );
  }

  Widget _buildSizeOptions(CartModel product) {
    // You'll need to implement this based on how you store size options
    // This is just a placeholder
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Text(
            'Size:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Chip(
            label: Text(product.size ?? 'N/A'),
            backgroundColor: Colors.grey[200],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(CartModel product) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              final isInCart = cartController.isInCart(product.id);
              final quantity = cartController.getQuantity(product.id);
              return ElevatedButton.icon(
                onPressed: () {
                  if (isInCart) {
                    cartController.updateQuantity(product.id, quantity + 1);
                    Get.snackbar(
                      'Updated Cart',
                      'Quantity of ${product.name} increased to ${quantity + 1}.',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  } else {
                    cartController.addToCart(product);
                    Get.snackbar(
                      'Added to Cart',
                      '${product.name} has been added to your cart.',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  }
                },
                icon: Icon(isInCart ? Icons.add_circle : Icons.add_shopping_cart),
                label: Text(isInCart ? 'Add Another ($quantity)' : 'Add to Cart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              );
            }),
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