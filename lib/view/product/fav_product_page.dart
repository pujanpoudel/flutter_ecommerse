import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:quick_cart/controller/product_controller.dart';
import 'package:quick_cart/models/product_model.dart';
import 'package:quick_cart/utils/bottom_nav_bar_widget.dart';
import 'package:quick_cart/utils/colors.dart';
import 'package:quick_cart/view/product/product_detail_page.dart';

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
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
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
                            child: const Icon(Icons.close),
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
            ],
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Obx(() {
      if (selectedProducts.isEmpty) {
        return FloatingActionButton.extended(
          onPressed: () {
            print('Adding all items to cart');
            Get.snackbar(
              'Items Added to Cart',
              'All items have been added to your cart.',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green.withOpacity(0.7),
              colorText: Colors.white,
            );
          },
          icon: const Icon(Icons.shopping_cart, color: Colors.white),
          label: const Text('Add all to cart',
              style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.mainColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        );
      } else {
        return FloatingActionButton.extended(
            onPressed: () {
              // Add selected items to cart
              print('Adding ${selectedProducts.length} items to cart');
              Get.snackbar(
                'Items Added to Cart',
                '${selectedProducts.length} items have been added to your cart.',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.green.withOpacity(0.7),
                colorText: Colors.white,
              );
              selectedProducts.clear();
            },
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            label: Text('Add ${selectedProducts.length} to cart'),
            backgroundColor: AppColors.mainColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ));
      }
    });
  }

  Widget _buildFavoriteProductCard(
      Product product, RxSet<String> selectedProducts) {
    final ProductController productController = Get.find<ProductController>();

    return Obx(() {
      final isSelected = selectedProducts.contains(product.id);

      return GestureDetector(
        onTap: () {
          if (isSelecting) {
            if (isSelected) {
              selectedProducts.remove(product.id);
            } else {
              selectedProducts.add(product.id);
            }
            if (selectedProducts.isEmpty) {
              setState(() {
                isSelecting = false;
              });
            }
          } else {
            Get.to(() =>
                ProductDetailPage(productId: product.id, product: product));
          }
        },
        onLongPress: () {
          if (!isSelecting) {
            setState(() {
              isSelecting = true;
            });
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              product.image.isNotEmpty ? product.image.first : 'default_image_url',
              fit: BoxFit.cover,
            ),
          ),
          if (isSelected)
            const Positioned(
              top: 8,
              left: 8,
              child: Icon(Icons.check_circle, color: AppColors.mainColor),
            ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                productController.toggleFavorite(product.id);
                selectedProducts.remove(product.id);
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                product.category.name,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
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
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                alignment: Alignment.topCenter,
              )),
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
