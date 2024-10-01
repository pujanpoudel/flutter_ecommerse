import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:quick_cart/controller/cart_controller.dart';
import 'package:quick_cart/controller/product_controller.dart';
import 'package:quick_cart/models/cart_model.dart';
import 'package:quick_cart/models/product_model.dart';
import 'package:quick_cart/utils/bottom_nav_bar_widget.dart';
import 'package:quick_cart/utils/colors.dart';
import 'package:quick_cart/view/product/product_detail_page.dart';

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

  String trimText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
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
                      onPressed: () {},
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
                            '${selectedProducts.length} selected',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.mainColor,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              selectedProducts.clear();
                            },
                            icon: const Icon(Icons.close),
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

  Future<List<Product>> _getFavoriteProducts(List<String> favoriteIds) async {
    List<Product> favoriteProducts = [];
    for (String id in favoriteIds) {
      Product? product = await productController.getProductById(id);
      if (product != null) {
        favoriteProducts.add(product);
      }
    }
    return favoriteProducts;
  }

  Widget _buildFloatingActionButton() {
    return Obx(() {
      if (selectedProducts.isEmpty) {
        return FloatingActionButton.extended(
          onPressed: () async {
            await productController.loadFavorites();
            final favoriteIds = productController.favoriteProductIds;

            if (favoriteIds.isEmpty) {
              Get.snackbar(
                'No Items Selected',
                'Please select items or add favorites to your cart.',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.red.withOpacity(0.7),
                colorText: Colors.white,
              );
            } else {
              List<Product> favoriteProducts =
                  await _getFavoriteProducts(favoriteIds.toList());

              for (var product in favoriteProducts) {
                cartController.addToCart(CartModel(
                  id: product.id,
                  name: product.name,
                  price: product.price,
                  description: product.description,
                  variant: product.variant
                      ?.map((variant) => CartVariant(
                            color: variant.color,
                            size: variant.size,
                            quantity: 1,
                          ))
                      .toList(),
                  imageUrl: product.image,
                  category: product.category.name,
                  vendor: product.vendor.storeName,
                  quantity: 1,
                ));
              }

              Get.snackbar(
                'Favorites Added to Cart',
                '${favoriteProducts.length} favorite items have been added to your cart.',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.green.withOpacity(0.7),
                colorText: Colors.white,
              );
            }
          },
          icon: const Icon(Icons.favorite, color: Colors.white),
          label: const Text('Add favorites to cart',
              style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.mainColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        );
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
            selectedProducts.clear();
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
                    ),
                  ),
                  if (isSelected)
                    const Positioned(
                      top: 8,
                      left: 8,
                      child:
                          Icon(Icons.check_circle, color: AppColors.mainColor),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        productController.toggleFavorite(product.id);
                        selectedProducts.remove(product);
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
                        trimText(product.name, 20),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${product.price}',
                        style: const TextStyle(color: AppColors.mainColor),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      productController.toggleFavorite(product.id);
                    },
                    icon: Icon(
                      productController.isFavorite(product.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: productController.isFavorite(product.id)
                          ? AppColors.mainColor
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
