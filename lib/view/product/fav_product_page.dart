import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quick_cart/controller/cart_controller.dart';
import 'package:quick_cart/controller/product_controller.dart';
import 'package:quick_cart/models/cart_model.dart';
import 'package:quick_cart/models/product_model.dart';
import 'package:quick_cart/utils/bottom_nav_bar_widget.dart';
import 'package:quick_cart/utils/colors.dart';
import 'package:quick_cart/view/product/product_detail_page.dart';
import 'home_page.dart';
import 'package:flutter/services.dart';

class FavoriteProductsPage extends StatefulWidget {
  const FavoriteProductsPage({super.key});

  @override
  FavoriteProductsPageState createState() => FavoriteProductsPageState();
}

class FavoriteProductsPageState extends State<FavoriteProductsPage> {
  final ProductController productController = Get.find<ProductController>();
  final CartController cartController = Get.find<CartController>();
  final ScrollController _scrollController = ScrollController();
  final RxList<Product> selectedProducts = <Product>[].obs;
  bool _isNavBarVisible = true;
  bool isSelecting = false;

  @override
  void initState() {
    super.initState();
    productController.loadFavorites();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isNavBarVisible) setState(() => _isNavBarVisible = false);
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isNavBarVisible) setState(() => _isNavBarVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String trimText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 3,
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
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              _buildSelectionBar(),
              Expanded(
                child: Obx(() {
                  if (productController.isLoading.value) {
                    return Center(
                        child: LoadingAnimationWidget.horizontalRotatingDots(
                            color: AppColors.mainColor, size: 50));
                  }

                  final favoriteProducts = productController.products
                      .where((p) =>
                          productController.favoriteProductIds.contains(p.id))
                      .toList();

                  if (favoriteProducts.isEmpty) {
                    return _buildEmptyState();
                  }

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
            ],
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildSelectionBar() {
    if (!isSelecting) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${selectedProducts.length} selected',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.mainColor,
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: _selectAllProducts,
                child: const Text('Select All'),
              ),
              TextButton(
                onPressed: _clearSelection,
                child: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/img/empty_favourite.png',
            width: 300,
            height: 300,
          ),
          const SizedBox(height: 20),
          const Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Add products to your favorites by pressing ❤️',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Get.to(() => const HomePage()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
            ),
            child: const Text(
              'Find more Products',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _selectAllProducts() {
    final allFavoriteProducts = productController.products
        .where((p) => productController.favoriteProductIds.contains(p.id))
        .toList();
    selectedProducts.assignAll(allFavoriteProducts);
  }

  void _clearSelection() {
    selectedProducts.clear();
    setState(() {
      isSelecting = false;
    });
  }

  Widget _buildFloatingActionButton() {
    return Obx(() {
      if (selectedProducts.isEmpty) {
        return const SizedBox.shrink();
      } else {
        return FloatingActionButton.extended(
          onPressed: () {
            for (var product in selectedProducts) {
              cartController.addToCart(CartModel(
                id: product.id,
                name: product.name,
                description: product.description,
                variant: [
                  CartVariant(
                    color: productController.selectedColor.value,
                    size: productController.selectedSize.value,
                  )
                ],
                imageUrl: product.image.isNotEmpty ? [product.image.first] : [],
                category: product.category.name,
                vendor: product.vendor.storeName,
                price: product.price,
                quantity: productController.selectedQuantity.value,
              ));
            }
            Get.snackbar(
              'Items Added to Cart',
              '${selectedProducts.length} items have been added to your cart.',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green.withOpacity(0.7),
              colorText: Colors.white,
            );
            _clearSelection();
          },
          icon: const Icon(Icons.shopping_cart, color: Colors.white),
          label: Text('Add ${selectedProducts.length} to cart'),
          backgroundColor: AppColors.mainColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        );
      }
    });
  }

  Widget _buildFavoriteProductCard(
      Product product, RxList<Product> selectedProducts) {
    final bool isSelected = selectedProducts.contains(product);

    return GestureDetector(
      onTap: () {
        if (isSelecting) {
          // Toggle selection when tapping in selection mode
          if (isSelected) {
            selectedProducts.remove(product);
          } else {
            selectedProducts.add(product);
          }
          if (selectedProducts.isEmpty) {
            setState(() {
              isSelecting = false;
            });
          }
        } else {
          Get.to(() => ProductDetailPage(productId: product.id));
        }
      },
      onLongPress: () {
        if (!isSelecting) {
          // Trigger haptic feedback when entering selection mode
          HapticFeedback.mediumImpact();
          setState(() {
            isSelecting = true;
          });
          selectedProducts.add(product);
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
                      product.image.isNotEmpty ? product.image.first : '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.error));
                      },
                    ),
                  ),
                  if (isSelecting)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          if (isSelected) {
                            selectedProducts.remove(product);
                          } else {
                            selectedProducts.add(product);
                          }
                          if (selectedProducts.isEmpty) {
                            setState(() {
                              isSelecting = false;
                            });
                          }
                        },
                        child: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isSelected
                              ? AppColors.mainColor
                              : Colors.grey[400],
                          size: 30,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                trimText(product.name, 25),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
