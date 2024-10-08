import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
  late List<Product> favoriteProducts;
  @override
  void initState() {
    super.initState();
    favoriteProducts = productController.favoriteProducts;
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

  @override
  Widget build(BuildContext context) {
    List<Product> favoriteProducts = productController.getFavoriteProducts();
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

                  favoriteProducts = productController.favoriteProducts;

                  if (favoriteProducts.isEmpty) {
                    return _buildEmptyState();
                  }

                  return GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: favoriteProducts.length,
                    itemBuilder: (context, index) => Obx(() {
                      return _buildFavoriteProductCard(
                        favoriteProducts[index],
                        selectedProducts,
                      );
                    }),
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
          Obx(
            () {
              final allSelected =
                  selectedProducts.length == favoriteProducts.length;

              return TextButton(
                onPressed: () => allSelected
                    ? _clearSelection()
                    : _selectAllProducts(favoriteProducts),
                child: Text(
                  allSelected
                      ? 'Deselect All (${selectedProducts.length} selected)'
                      : 'Select All (${selectedProducts.length} selected)',
                ),
              );
            },
          ),
          Row(
            children: [
              TextButton(
                onPressed: _clearSelection,
                child: const Text(
                  'Exit',
                  style: TextStyle(color: AppColors.blackColor),
                ),
              ),
              TextButton(
                onPressed: () {
                  productController.removeFavorites(selectedProducts.toList());
                  selectedProducts.clear();
                },
                child: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectAllProducts(List<Product> displayedProducts) {
    selectedProducts.assignAll(displayedProducts);
  }

  void _clearSelection() {
    selectedProducts.clear();
    setState(() {
      isSelecting = false;
    });
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

  Widget _buildFloatingActionButton() {
    if (favoriteProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      onPressed: favoriteProducts.isNotEmpty
          ? () {
              List<Product> productsToAdd = selectedProducts.isNotEmpty
                  ? selectedProducts
                  : favoriteProducts;

              for (var product in productsToAdd) {
                _initializeDefaultSelections(product);
                bool hasColorVariant = product.variant!
                    .any((v) => v.color != null && v.color!.isNotEmpty);
                bool hasSizeVariant = product.variant!
                    .any((v) => v.size != null && v.size!.isNotEmpty);
                bool isColorSelected = hasColorVariant &&
                    productController.selectedColor.value.isNotEmpty;
                bool isSizeSelected = hasSizeVariant &&
                    productController.selectedSize.value.isNotEmpty;
                if ((hasColorVariant && !isColorSelected) ||
                    (hasSizeVariant && !isSizeSelected)) {
                  Get.snackbar('Error',
                      'Please select both color and size variants for ${product.name}.',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: const Color.fromARGB(19, 152, 64, 20));
                  return;
                }

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
                  imageUrl:
                      product.image.isNotEmpty ? [product.image.first] : [],
                  category: product.category.name,
                  vendor: product.vendor.storeName,
                  price: product.price,
                  quantity: productController.selectedQuantity.value,
                ));
              }
              Get.snackbar(
                'Added to Cart',
                '${productsToAdd.length} items have been added to your cart.',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.green.withOpacity(0.7),
                colorText: Colors.white,
              );

              _clearSelection();
            }
          : null,
      icon: const Icon(Icons.shopping_cart, color: Colors.white),
      label: Obx(() => Text(
            selectedProducts.isNotEmpty
                ? 'Add ${selectedProducts.length} items to cart'
                : 'Add all items to cart',
            style: const TextStyle(color: Colors.white),
          )),
      backgroundColor: AppColors.mainColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }

  void _initializeDefaultSelections(Product product) {
    List<String> availableColors = product.variant
            ?.where(
                (variant) => variant.color != null && variant.color!.isNotEmpty)
            .map((variant) => variant.color!)
            .toSet()
            .toList() ??
        [];
    List<String> availableSizes = product.variant
            ?.where(
                (variant) => variant.size != null && variant.size!.isNotEmpty)
            .map((variant) => variant.size!)
            .toSet()
            .toList() ??
        [];

    if (availableColors.isNotEmpty &&
        productController.selectedColor.value.isEmpty) {
      productController.updateSelectedColor(availableColors.first);
    }

    if (availableSizes.isNotEmpty &&
        productController.selectedSize.value.isEmpty) {
      productController.updateSelectedSize(availableSizes.first);
    }
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
          HapticFeedback.heavyImpact();

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
                        productController.toggleFavorite(product);
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
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'NRP ${product.price.round()}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      productController.isFavorite(product.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: productController.isFavorite(product.id)
                          ? Colors.red
                          : Colors.grey[600],
                    ),
                    onPressed: () {
                      productController.toggleFavorite(product);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    alignment: Alignment.topCenter,
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
