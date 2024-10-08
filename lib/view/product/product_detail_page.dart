import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quick_cart/controller/cart_controller.dart';
import 'package:quick_cart/controller/product_controller.dart';
import 'package:quick_cart/models/cart_model.dart';
import 'package:quick_cart/models/product_model.dart';
import 'package:quick_cart/utils/colors.dart';
import 'package:quick_cart/view/cart/cart_page.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final ProductController productController = Get.find<ProductController>();
  final CartController cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<CartModel?>(
        future: productController.getProductAsCartModel(widget.productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: LoadingAnimationWidget.horizontalRotatingDots(
                    color: AppColors.mainColor, size: 50));
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error: Product not found'));
          }

          final product = snapshot.data!;
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  _buildSliverAppBar(product),
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProductInfo(product),
                          _buildSizeColorOptions(product),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).padding.bottom + 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              _buildBottomBar(product),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(CartModel product) {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(Get.context!).size.height * 0.4,
      pinned: true,
      backgroundColor: Colors.black.withOpacity(0.3),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: MediaQuery.of(Get.context!).size.height,
                viewportFraction: 1.0,
                enlargeCenterPage: false,
                enableInfiniteScroll: false,
              ),
              items: product.imageUrl.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    );
                  },
                );
              }).toList(),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () => Get.to(() => const CartPage()),
              ),
              Obx(() {
                int itemCount = cartController.cartItems.length;
                if (itemCount > 0) {
                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        itemCount > 9 ? '9+' : itemCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo(CartModel product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            'By: ${product.vendor}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          _buildExpandableDescription(product),
        ],
      ),
    );
  }

  Widget _buildBottomBar(CartModel cartProduct) {
    return Positioned(
      bottom: 5,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: () async {
                          Product? product = await productController
                              .getProductById(cartProduct.id);

                          if (product != null) {
                            productController.toggleFavorite(product);
                          } else {
                            Get.snackbar('Error', 'Product not found.');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor:
                              productController.isFavorite(cartProduct.id)
                                  ? Colors.red
                                  : Colors.grey[600],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                                color: Colors.grey.withOpacity(0.3), width: 1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              productController.isFavorite(cartProduct.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  productController.isFavorite(cartProduct.id)
                                      ? Colors.red
                                      : Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Favorite",
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    productController.isFavorite(cartProduct.id)
                                        ? Colors.red
                                        : Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: Obx(() {
                    String selectedSize = productController.selectedSize.value;
                    String selectedColor =
                        productController.selectedColor.value;
                    int stock = cartController.getStockForSelectedOptions(
                        selectedSize, selectedColor);
                    return Text(
                      'Available: $stock',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _buildQuantitySelector(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.snackbar(
                            'Buy Now', '${cartProduct.name} To be added');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Buy Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        bool hasColorVariant = cartProduct.variant!
                            .any((v) => v.color != null && v.color!.isNotEmpty);
                        bool hasSizeVariant = cartProduct.variant!
                            .any((v) => v.size != null && v.size!.isNotEmpty);
                        bool isColorSelected = hasColorVariant &&
                            productController.selectedColor.value.isNotEmpty;
                        bool isSizeSelected = hasSizeVariant &&
                            productController.selectedSize.value.isNotEmpty;
                        if ((hasColorVariant && !isColorSelected) ||
                            (hasSizeVariant && !isSizeSelected)) {
                          Get.snackbar('Error',
                              'Please select both color and size variants.');
                          return;
                        }
                        cartController.addToCart(CartModel(
                          id: cartProduct.id,
                          name: cartProduct.name,
                          description: cartProduct.description,
                          variant: [
                            CartVariant(
                              color: productController.selectedColor.value,
                              size: productController.selectedSize.value,
                            ),
                          ],
                          imageUrl: cartProduct.imageUrl,
                          category: cartProduct.category,
                          vendor: cartProduct.vendor,
                          price: cartProduct.price,
                          quantity: productController.selectedQuantity.value,
                        ));
                        Get.snackbar(
                          'Added to Cart',
                          '${cartProduct.name} was added to your cart.',
                          backgroundColor: Colors.green.withOpacity(0.7),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableDescription(CartModel product) {
    return Obx(() {
      bool showFullDescription = productController.showFullDescription.value;
      const textStyle = TextStyle(fontSize: 14);
      final textSpan = TextSpan(
        text: product.description,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        maxLines: 5,
      );
      textPainter.layout(maxWidth: MediaQuery.of(Get.context!).size.width - 32);

      bool isTextOverflowing = textPainter.didExceedMaxLines;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.description?.isNotEmpty == true ? product.description! : '',
            style: textStyle,
            maxLines: showFullDescription ? null : 5,
            overflow: TextOverflow.fade,
          ),
          if (isTextOverflowing && (product.description?.isNotEmpty == true))
            GestureDetector(
              onTap: () {
                productController.toggleDescription();
              },
              child: Text(
                showFullDescription ? 'Hide' : 'Show All',
                style: const TextStyle(color: AppColors.mainColor),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildSizeColorOptions(CartModel product) {
    if (product.variant == null || product.variant!.isEmpty) {
      return const SizedBox.shrink();
    }
    _initializeDefaultSelections(product);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSizeSelector(product),
          const SizedBox(height: 8),
          _buildColorSelector(product),
        ],
      ),
    );
  }

  void _initializeDefaultSelections(CartModel product) {
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

  Widget _buildColorSelector(CartModel product) {
    List<String> availableColors = product.variant
            ?.where(
                (variant) => variant.color != null && variant.color!.isNotEmpty)
            .map((variant) => variant.color!)
            .toSet()
            .toList() ??
        [];

    if (availableColors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        const Text(
          'Color:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: 8,
            children: availableColors.map((color) {
              return Obx(() {
                bool isSelected =
                    color == productController.selectedColor.value;
                return ChoiceChip(
                  label: Text(color),
                  selected: isSelected,
                  selectedColor: AppColors.mainColor,
                  backgroundColor: Colors.grey[200],
                  showCheckmark: false,
                  onSelected: (selected) {
                    if (isSelected) {
                      productController.updateSelectedColor('');
                    } else {
                      productController.updateSelectedColor(color);
                    }
                  },
                );
              });
            }).toList(),
          ),
        )
      ],
    );
  }

  Widget _buildSizeSelector(CartModel product) {
    List<String> availableSizes = product.variant
            ?.where(
                (variant) => variant.size != null && variant.size!.isNotEmpty)
            .map((variant) => variant.size!)
            .toSet()
            .toList() ??
        [];
    if (availableSizes.isEmpty) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        const Text(
          'Size:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: 8,
            children: availableSizes.map((size) {
              return Obx(() {
                bool isSelected = size == productController.selectedSize.value;
                return ChoiceChip(
                  label: Text(size),
                  selected: isSelected,
                  selectedColor: AppColors.mainColor,
                  backgroundColor: Colors.grey[200],
                  showCheckmark: false,
                  onSelected: (selected) {
                    if (isSelected) {
                      productController.updateSelectedSize('');
                    } else {
                      productController.updateSelectedSize(size);
                    }
                  },
                );
              });
            }).toList(),
          ),
        )
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                productController.decreaseQuantity();
              },
            ),
            Text(
              '${productController.selectedQuantity}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                productController.increaseQuantity();
              },
            ),
          ],
        ),
      );
    });
  }
}
