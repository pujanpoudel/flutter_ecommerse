import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:quick_cart/controller/cart_controller.dart';
import 'package:quick_cart/controller/product_controller.dart';
import 'package:quick_cart/models/cart_model.dart';
import 'package:quick_cart/utils/bottom_nav_bar_widget.dart';
import 'package:quick_cart/utils/colors.dart';
import 'package:quick_cart/view/product/checkout_page.dart';
import 'package:quick_cart/view/product/home_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  CartPageState createState() => CartPageState();
}

class CartPageState extends State<CartPage> {
  final CartController cartController = Get.find<CartController>();
  final ScrollController _scrollController = ScrollController();
  final ProductController productController = Get.find<ProductController>();

  bool _isNavBarVisible = true;
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
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

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        cartController.clearSelection();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 2,
      isNavBarVisible: _isNavBarVisible,
      body: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              if (_isSelectionMode) _buildSelectionBar(),
              Expanded(
                child: Obx(() {
                  if (cartController.cartItems.isEmpty) {
                    return _buildEmptyCart();
                  } else {
                    return _buildCartItemList();
                  }
                }),
              ),
              _buildTotalAndCheckoutSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Cart',
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionBar() {
    return Obx(() {
      if (!cartController.isSelectionMode.value) return const SizedBox.shrink();

      final allSelected = cartController.selectedItems.length ==
          cartController.cartItems.length;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => allSelected
                  ? cartController.clearSelection()
                  : cartController.selectAllItems(),
              child: Text(
                allSelected
                    ? 'Deselect All (${cartController.selectedItems.length} selected)'
                    : 'Select All (${cartController.selectedItems.length} selected)',
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: cartController.clearSelection,
                  child: const Text(
                    'Exit',
                    style: TextStyle(color: AppColors.blackColor),
                  ),
                ),
                TextButton(
                  onPressed: cartController.removeSelectedItems,
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
    });
  }

  Widget _buildCartItemList() {
    return Obx(() => ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          children: cartController.cartItems
              .map((item) => GestureDetector(
                    onLongPress: () {
                      if (!_isSelectionMode) {
                        _toggleSelectionMode();
                      }
                      cartController.toggleItemSelection(item.id);
                    },
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.network(
                                      item.imageUrl.first,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              if (item.variant != null &&
                                                  item.variant!.isNotEmpty &&
                                                  item.variant![0].color !=
                                                      null)
                                                Text(
                                                  'Color: ${item.variant![0].color}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              if (item.variant != null &&
                                                  item.variant!.isNotEmpty &&
                                                  item.variant![0].size != null)
                                                Text(
                                                  'Size: ${item.variant![0].size}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'NRS ${item.price.round()}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.mainColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () {
                                            cartController.removeFromCart(item);
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove),
                                              onPressed: () {
                                                if (item.quantity > 1) {
                                                  CartVariant? selectedVariant =
                                                      cartController
                                                          .getSelectedVariant(
                                                              item);
                                                  cartController.updateQuantity(
                                                    item.id,
                                                    item.quantity - 1,
                                                    color:
                                                        selectedVariant!.color,
                                                    size: selectedVariant.size,
                                                  );
                                                }
                                              },
                                            ),
                                            Text(
                                              item.quantity.toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: () {
                                                CartVariant? selectedVariant =
                                                    cartController
                                                        .getSelectedVariant(
                                                            item);
                                                cartController.updateQuantity(
                                                  item.id,
                                                  item.quantity + 1,
                                                  color: selectedVariant?.color,
                                                  size: selectedVariant?.size,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            if (_isSelectionMode)
                              Positioned.fill(
                                child: Obx(
                                    () => cartController.isItemSelected(item.id)
                                        ? Container(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            child: const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          )
                                        : const SizedBox.shrink()),
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ))
              .toList(),
        ));
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/img/empty_cart.png',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 20),
          const Text(
            'Your cart is empty!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Looks like you haven't made\nyour mind yet.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Get.to(() => const HomePage());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
            ),
            child: const Text(
              'Browse some more',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalAndCheckoutSection() {
    return Obx(() {
      if (cartController.cartItems.isEmpty) {
        return const SizedBox.shrink();
      }
      double totalAmount = cartController.totalAmount;
      double discount = 0.0;
      if (cartController.cartItems.length > 5) {
        discount = totalAmount * 0.1;
        totalAmount *= 0.9;
      }
      return Container(
        padding: const EdgeInsets.all(16),
        color: const Color.fromARGB(255, 245, 245, 245),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Offers/ Coupons',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 241, 220, 202),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Item Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        'NRS ${cartController.totalAmount.round()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        discount > 0 ? 'Discount (10%)' : 'Discount',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        'NRS ${discount.round()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.grey, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'NRS ${totalAmount.round()}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mainColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor: AppColors.mainColor,
                ),
                onPressed: () {
                  if (!_isSelectionMode) {
                    Get.to(const CheckoutPage());
                  } else {
                    cartController.removeSelectedItems();
                    _toggleSelectionMode();
                  }
                },
                child: const Text(
                  'Checkout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
