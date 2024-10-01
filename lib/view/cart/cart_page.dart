import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:quick_cart/controller/cart_controller.dart';
import 'package:quick_cart/utils/bottom_nav_bar_widget.dart';
import 'package:quick_cart/utils/colors.dart';
import 'package:quick_cart/view/cart/cart_item.dart';
import 'package:quick_cart/view/product/checkout_page.dart';
import 'package:quick_cart/view/product/home_page.dart';

class CartPage extends StatefulWidget {
  CartPage({super.key});
  final CartController cartController = Get.find<CartController>();

  @override
  CartPageState createState() => CartPageState();
}

class CartPageState extends State<CartPage> {
  final CartController cartController = Get.find<CartController>();
  final ScrollController _scrollController = ScrollController();
  bool _isNavBarVisible = true;

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

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 2,
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
                      'My Cart',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Obx(() => cartController.selectedItems.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${cartController.selectedItems.length} selected',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.mainColor,
                            ),
                          ),
                          TextButton(
                            onPressed: cartController.removeSelectedItems,
                            child: const Text('Delete Selected'),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink()),
              Expanded(
                child: Obx(() {
                  if (cartController.cartItems.isEmpty) {
                    return _buildEmptyCart();
                  } else {
                    return ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      children: [
                        ...cartController.cartItems.map((item) =>
                            GestureDetector(
                              onTap: () =>
                                  cartController.toggleItemSelection(item.id),
                              child: Stack(
                                children: [
                                  CartItem(
                                    item: item,
                                    onQuantityChanged: (quantity) {
                                      cartController.updateQuantity(
                                          item.id, quantity);
                                    },
                                    onDelete: () {
                                      cartController.removeFromCart(item.id);
                                    },
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => cartController
                                          .removeFromCart(item.id),
                                    ),
                                  ),
                                  Obx(() =>
                                      cartController.isItemSelected(item.id)
                                          ? Positioned.fill(
                                              child: Container(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                child: const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 40,
                                                ),
                                              ),
                                            )
                                          : const SizedBox.shrink()),
                                ],
                              ),
                            )),
                      ],
                    );
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
              Get.to(const HomePage());
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

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total amount:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'NRS ${cartController.totalAmount.round()}',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mainColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (cartController.selectedItems.isEmpty) {
                    Get.to(const CheckoutPage());
                  } else {
                    cartController.removeSelectedItems();
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      cartController.selectedItems.isEmpty
                          ? Icons.payment
                          : Icons.delete,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      cartController.selectedItems.isEmpty
                          ? 'Check Out'
                          : 'Delete from Cart',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
