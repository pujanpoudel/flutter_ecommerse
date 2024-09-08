import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:quick_cart/controller/product_controller.dart';
import 'package:quick_cart/models/product_model.dart';
import 'package:quick_cart/utils/bottom_nav_bar_widget.dart';
import 'package:quick_cart/utils/colors.dart';

class FavoriteProductsPage extends StatefulWidget {
  const FavoriteProductsPage({super.key});

  @override
  _FavoriteProductsPageState createState() => _FavoriteProductsPageState();
}

class _FavoriteProductsPageState extends State<FavoriteProductsPage> {
  final ProductController productController = Get.find<ProductController>();
  final ScrollController _scrollController = ScrollController();
  bool _isNavBarVisible = true;
  final RxSet<String> selectedProducts = <String>{}.obs;
  bool isSelecting = false;

  @override
  void initState() {
    super.initState();

    // Listen to scroll changes for hiding/showing the bottom navigation bar
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isNavBarVisible) {
          setState(() {
            _isNavBarVisible = false;
          });
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isNavBarVisible) {
          setState(() {
            _isNavBarVisible = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex:
          3, // Set to the appropriate index for Favorites in your bottom navigation bar
      isNavBarVisible: _isNavBarVisible,
      body: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Favorites',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        // Implement search functionality
                      },
                    ),
                  ],
                ),
              ),
              Obx(() => selectedProducts.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${selectedProducts.length} item(s) selected',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.mainColor,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              selectedProducts.clear();
                            },
                            child: Icon(Icons.close),
                            // const Text(
                            //   'Deselect all',
                            //   style: TextStyle(color: Colors.red),
                            // ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink()),
              Expanded(
                child: Obx(() {
                  final favoriteProducts = productController.products
                      .where((p) => productController.isFavorite(p.id))
                      .toList();
                  return GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: favoriteProducts.length,
                    itemBuilder: (context, index) => _buildFavoriteProductCard(
                      favoriteProducts[index],
                      selectedProducts,
                    ),
                  );
                }),
              ),
              Obx(() => selectedProducts.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 200,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Add selected items to cart
                            print(
                                'Adding ${selectedProducts.length} items to cart');
                            Get.snackbar(
                              'Items Added to Cart',
                              '${selectedProducts.length} items have been added to your cart.',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.green.withOpacity(0.7),
                              colorText: Colors.white,
                            );
                            selectedProducts.clear();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mainColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.shopping_cart,
                              color: Colors.white),
                          label: Text(
                              'Add ${selectedProducts.length} items to cart'),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 200,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Add all favorite items to cart
                            print('Adding all items to cart');
                            Get.snackbar(
                              'Items Added to Cart',
                              'All items have been added to your cart.',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.green.withOpacity(0.7),
                              colorText: Colors.white,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mainColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.shopping_cart,
                              color: Colors.white),
                          label: const Text('Add all to cart'),
                        ),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteProductCard(
      Product product, RxSet<String> selectedProducts) {
    final ProductController productController = Get.find<ProductController>();

    return Obx(() {
      final isSelected = selectedProducts.contains(product.id);

      return GestureDetector(
        onTap: (
        
        ) {
          if (isSelecting) {
            // If already selecting, tap to select/deselect items
            if (isSelected) {
              selectedProducts.remove(product.id);
            } else {
              selectedProducts.add(product.id);
            }
          } else {
            
          }
        },
        onLongPress: () {
          if (!isSelecting) {
            isSelecting = true; // Start selection mode
            selectedProducts.add(product.id);
          }
        },
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? AppColors.mainColor : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(8)),
                      child: Image.network(
                        product.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () =>
                            productController.toggleFavorite(product.id),
                      ),
                    ),
                    if (isSelected)
                      const Positioned(
                        top: 8,
                        left: 8,
                        child: Icon(Icons.check_circle,
                            color: AppColors.mainColor),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category.toString(),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
