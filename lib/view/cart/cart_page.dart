import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:quick_cart/controller/cart_controller.dart';
import 'package:quick_cart/utils/colors.dart';
import 'package:quick_cart/view/cart/cart_item.dart';
import 'package:quick_cart/utils/bottom_nav_bar_widget.dart';
import 'package:quick_cart/view/product/checkout_page.dart';
import 'package:quick_cart/view/product/home_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartController cartController = Get.find<CartController>();
  final ScrollController _scrollController = ScrollController();
  bool _isNavBarVisible = true;
  final RxSet<String> selectedItems = <String>{}.obs;

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

  void _removeSelectedItems() {
    for (String itemId in selectedItems) {
      cartController.removeFromCart(itemId);
    }
    selectedItems.clear();
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
                      'My Bag',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Obx(() => selectedItems.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${selectedItems.length} item(s) selected',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.mainColor,
                            ),
                          ),
                          TextButton(
                            onPressed: _removeSelectedItems,
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
                        ...cartController.cartItems
                            .map((item) => GestureDetector(
                                  onLongPress: () {
                                    if (selectedItems.contains(item.id)) {
                                      selectedItems.remove(item.id);
                                    } else {
                                      selectedItems.add(item.id);
                                    }
                                  },
                                  child: Stack(
                                    children: [
                                      CartItem(item: item),
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
                                      Obx(() => selectedItems.contains(item.id)
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
                        const SizedBox(height: 16),
                        _buildPromoCode(),
                        const SizedBox(height: 16),
                        _buildTotalAmount(),
                        const SizedBox(height: 16),
                        _buildCheckoutButton(),
                      ],
                    );
                  }
                }),
              ),
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
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Text(
              'Start Shopping',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCode() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Enter your promo code',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            // Implement promo code logic
          },
        ),
      ],
    );
  }

  Widget _buildTotalAmount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total amount:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Obx(() => Text(
              '${cartController.totalAmount}\$',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mainColor),
            )),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mainColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () {
          Get.to(CheckoutPage());
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment,
              color: Colors.white,
            ),
            SizedBox(width: 5),
            Text(
              'Check Out',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
