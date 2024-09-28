import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_cart/models/cart_model.dart';
import 'package:quick_cart/view/payment/esewa.dart';
import 'package:quick_cart/view/payment/khalti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../repo/product_repo.dart';

class CartController extends GetxController {
  late final ProductRepo productRepo;
  final RxList<Product> products = <Product>[].obs;
  RxList<CartModel> cartItems = <CartModel>[].obs;
  RxString selectedPaymentMethod = 'eSewa'.obs;
  RxSet<String> selectedItems = <String>{}.obs;
  var product = Rxn<Product>();
  var selectedSize = ''.obs;
  var selectedColor = ''.obs;
  var selectedQuantity = 1.obs;
  var selectedProducts = <Product>[].obs;


  @override
  void onInit() {
    super.onInit();
    loadCartItems();
  }

  Future<void> loadCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList('cartItems') ?? [];
    cartItems.value =
        items.map((item) => CartModel.fromJson(json.decode(item))).toList();
  }

  Future<void> saveCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final items = cartItems.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList('cartItems', items);
  }

  void addToCart(CartModel item) {
    final index = cartItems.indexWhere((element) =>
        element.id == item.id &&
        element.variant?.first.color == item.variant?.first.color &&
        element.variant?.first.size == item.variant?.first.size);

    if (index != -1) {
      cartItems[index].quantity += item.quantity;
    } else {
      cartItems.add(item);
    }
    saveCartItems();
  }

  void removeFromCart(String productId, {String? color, String? size}) {
    cartItems.removeWhere((item) =>
        item.id == productId &&
        item.variant!
            .any((variant) => variant.color == color && variant.size == size));
    selectedItems.remove(productId);
    saveCartItems();
  }

  void updateQuantity(String productId, int quantity,
      {String? color, String? size}) {
    final index = cartItems.indexWhere((item) =>
        item.id == productId &&
        item.variant!
            .any((variant) => variant.color == color && variant.size == size));

    if (index != -1) {
      final itemVariant = cartItems[index].variant!.firstWhere(
          (variant) => variant.color == color && variant.size == size);
      if (quantity > itemVariant.stock!) {
        quantity = itemVariant.stock!;
      }

      itemVariant.quantity = quantity;

      if (itemVariant.quantity <= 0) {
        cartItems[index].variant!.remove(itemVariant);
        if (cartItems[index].variant!.isEmpty) {
          cartItems.removeAt(index);
          selectedItems.remove(productId);
        }
      }

      saveCartItems();
    }
  }

  void toggleItemSelection(String itemId) {
    if (selectedItems.contains(itemId)) {
      selectedItems.remove(itemId);
    } else {
      selectedItems.add(itemId);
    }
  }

  bool isItemSelected(String itemId) {
    return selectedItems.contains(itemId);
  }

  void removeSelectedItems() {
    cartItems.removeWhere((item) => selectedItems.contains(item.id));
    selectedItems.clear();
    saveCartItems();
  }

  bool isInCart(String productId, {String? color, String? size}) {
    return cartItems.any((item) =>
        item.id == productId &&
        item.variant!
            .any((variant) => variant.color == color && variant.size == size));
  }

  int getQuantity(String productId, {String? color, String? size}) {
    final item = cartItems.firstWhere(
        (item) =>
            item.id == productId &&
            item.variant!.any(
                (variant) => variant.color == color && variant.size == size),
        orElse: () => CartModel(
              id: productId,
              name: '',
              description: '',
              variant: [
                CartVariant(size: size ?? '', color: color ?? '', stock: 0)
              ],
              imageUrl: [],
              category: '',
              vendor: '',
              price: 0,
              quantity: 0,
            ));
    return item.quantity;
  }

  CartVariant? getSelectedVariant(CartModel cartItem) {
    return cartItem.variant?.isNotEmpty == true
        ? cartItem.variant!.first
        : null;
  }

  void submitOrder() {
    if (selectedPaymentMethod.value == 'eSewa') {
      Esewa esewa = Esewa();
      esewa.pay(this);
      Get.snackbar(
        'Payment Success',
        'Your order has been placed successfully through eSewa!',
        icon: const Icon(Icons.check_circle, color: Colors.green),
        snackPosition: SnackPosition.TOP,
      );
    } else if (selectedPaymentMethod.value == 'Khalti') {
      // KhaltiScope;
      Get.to(() => Khalti());
    } else if (selectedPaymentMethod.value == "COD") {
      Get.snackbar(
        'Order Success',
        'Your order has been placed successfully!',
        icon: const Icon(Icons.check_circle, color: Colors.green),
        snackPosition: SnackPosition.TOP,
      );
    } else {
      Get.snackbar(
        'Payment Method Required',
        'Please select a payment method to proceed.',
        icon: const Icon(Icons.error, color: Colors.red),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  int getStockForSelectedOptions(String selectedSize, String selectedColor) {
    if (product.value != null) {
      Variant? selectedVariant = product.value!.variants.firstWhereOrNull(
            (v) => v.size == selectedSize && v.color == selectedColor,
      );
      return selectedVariant?.stock ?? 0;
    }
    return 0;
  }

  double get totalAmount =>
      cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));


  int get cartItemCount => cartItems.length;

  void toggleProductSelection(Product product) {
    if (selectedProducts.contains(product)) {
      selectedProducts.remove(product);
    } else {
      selectedProducts.add(product);
    }
  }

  List<Product> get selectedProductList => selectedProducts.toList();
}
