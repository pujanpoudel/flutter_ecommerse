import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quick_cart/controller/cart_controller.dart';
import 'package:quick_cart/controller/product_controller.dart';
import 'package:quick_cart/models/cart_model.dart';
import 'package:quick_cart/utils/colors.dart';
import 'package:quick_cart/view/cart/cart_page.dart';

class ProductDetailPage extends StatelessWidget {
  final String productId;
  final ProductController productController = Get.find<ProductController>();
  final CartController cartController = Get.find<CartController>();

  ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<CartModel?>(
        future: productController.getProductAsCartModel(productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: LoadingAnimationWidget.horizontalRotatingDots(
                color: AppColors.mainColor, size: 50));
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error: Product not found'));
          }

          final product = snapshot.data!;
          return CustomScrollView(
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
                      _buildQuantityAndAddToCart(product),
                      SizedBox(height: MediaQuery.of(context).padding.bottom),
                    ],
                  ),
                ),
              ),
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
      backgroundColor: AppColors.mainColor.withOpacity(0.1),
      flexibleSpace: FlexibleSpaceBar(
        background: CarouselSlider(
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
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        onPressed: () => Get.back(),
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shopping_cart, color: Colors.black),
              ),
              onPressed: () => Get.to(() => CartPage()),
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
      ],
    );
  }

  Widget _buildProductInfo(CartModel product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'By: ${product.vendor}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                  )),
            ],
          ),
          const SizedBox(height: 10),
          _buildExpandableDescription(product),
        ],
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

  Widget _buildColorSelector(CartModel product) {
    List<String?> availableColors =
        product.variant?.map((variant) => variant.color).toSet().toList() ?? [];

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
                  label: Text(color!),
                  selected: isSelected,
                  selectedColor: AppColors.mainColor,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
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
    List<String?> availableSizes =
        product.variant?.map((variant) => variant.size).toSet().toList() ?? [];

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
                  label: Text(size!),
                  selected: isSelected,
                  selectedColor: AppColors.mainColor,
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

  Widget _buildQuantityAndAddToCart(CartModel product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuantitySelector(),
                const SizedBox(height: 4),
                Obx(() {
                  String selectedSize = productController.selectedSize.value;
                  String selectedColor = productController.selectedColor.value;
                  int stock = cartController.getStockForSelectedOptions(
                      selectedSize, selectedColor);
                  return Text(
                    'Available: $stock',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (productController.selectedColor.value.isNotEmpty &&
                    productController.selectedSize.value.isNotEmpty) {
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
                    imageUrl: product.imageUrl,
                    category: product.category,
                    vendor: product.vendor,
                    price: product.price,
                    quantity: productController.selectedQuantity.value,
                  ));

                  Get.snackbar('Added to Cart',
                      '${product.name} was added to your cart.');
                } else {
                  Get.snackbar('Error', 'Please select a color and size');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Add to Cart',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
