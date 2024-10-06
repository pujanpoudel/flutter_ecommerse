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
  RxString selectedPaymentMethod = 'eSewa'.obs;
  RxSet<String> selectedItems = <String>{}.obs;
  var product = Rxn<Product>();
  final Rx<String> selectedColor = ''.obs;
  final Rx<String> selectedSize = ''.obs;
  var selectedQuantity = 1.obs;
  var selectedProducts = <Product>[].obs;
  final RxList<CartModel> cartItems = <CartModel>[].obs;
  final RxBool isSelectionMode = false.obs;

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
    bool variantsMatch(CartVariant? v1, CartVariant? v2) {
      if (v1 == null && v2 == null) return true;
      if (v1 == null || v2 == null) return false;
      return (v1.color == v2.color || v1.color == null || v2.color == null) &&
          (v1.size == v2.size || v1.size == null || v2.size == null);
    }

    final index = cartItems.indexWhere((element) =>
        element.id == item.id &&
        variantsMatch(element.variant?.firstOrNull, item.variant?.firstOrNull));

    if (index != -1) {
      cartItems[index].quantity += item.quantity;
    } else {
      cartItems.add(item);
    }
    saveCartItems();
  }

  void removeFromCart(CartModel item) {
    cartItems.removeWhere((element) => element.id == item.id);
    cartItems.remove(item);
    saveCartItems();
  }

  void clearCart() {
    cartItems.clear();
    saveCartItems();
  }

  void updateQuantity(String productId, int quantity,
      {String? color, String? size}) {
    final index = cartItems.indexWhere((item) =>
        item.id == productId &&
        item.variant!
            .any((variant) => variant.color == color && variant.size == size));

    if (index != -1) {
      final List<CartModel> updatedItems = List.from(cartItems);
      final item = updatedItems[index];
      final itemVariant = item.variant!.firstWhere(
          (variant) => variant.color == color && variant.size == size);
      if (quantity > itemVariant.stock!) {
        quantity = itemVariant.stock!;
      }
      itemVariant.quantity = quantity;
      item.quantity = quantity;
      if (quantity <= 0) {
        item.variant!.remove(itemVariant);
        if (item.variant!.isEmpty) {
          updatedItems.removeAt(index);
          selectedItems.remove(productId);
        }
      }
      cartItems.value = updatedItems;
      saveCartItems();
    }
  }

  CartVariant? getSelectedVariant(CartModel item) {
    if (item.variant == null || item.variant!.isEmpty) {
      return null;
    }
    return item.variant!.first;
  }

  void updateSelectedSize(String size) {
    selectedSize.value = size;
  }

  void updateSelectedColor(String color) {
    selectedColor.value = color;
  }

  void selectAllItems() {
    selectedItems.assignAll(cartItems.map((item) => item.id).toSet());
    checkSelectionMode();
  }

  void clearSelection() {
    selectedItems.clear();
    checkSelectionMode();
  }

  void removeSelectedItems() {
    cartItems.removeWhere((item) => selectedItems.contains(item.id));
    clearSelection();
  }

  void toggleItemSelection(String id) {
    if (selectedItems.contains(id)) {
      selectedItems.remove(id);
    } else {
      selectedItems.add(id);
    }
    checkSelectionMode();
  }

  void checkSelectionMode() {
    if (selectedItems.isEmpty) {
      isSelectionMode.value = false;
    } else if (!isSelectionMode.value) {
      isSelectionMode.value = true;
    }
  }

  List<Product> get selectedProductList => selectedProducts.toList();

  double get totalAmount =>
      cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

  int get cartItemCount => cartItems.length;

  bool isItemSelected(String itemId) {
    return selectedItems.contains(itemId);
  }

  bool isInCart(String productId, {String? color, String? size}) {
    return cartItems.any((item) =>
        item.id == productId &&
        item.variant!
            .any((variant) => variant.color == color && variant.size == size));
  }

  int getItemQuantity(String productId, {String? color, String? size}) {
    final item = cartItems.firstWhereOrNull((item) =>
        item.id == productId &&
        item.variant!
            .any((variant) => variant.color == color && variant.size == size));

    if (item != null) {
      final variant = item.variant!.firstWhereOrNull(
          (variant) => variant.color == color && variant.size == size);
      return variant?.quantity ?? 0;
    }
    return 0;
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

  int getStockForSelectedOptions(String? selectedSize, String? selectedColor) {
    if (product.value != null && product.value!.variant != null) {
      Variant? selectedVariant = product.value!.variant!.firstWhereOrNull(
        (v) {
          if (selectedSize == null) {
            return v.color == selectedColor;
          } else if (selectedColor == null) {
            return v.size == selectedSize;
          } else {
            return v.size == selectedSize && v.color == selectedColor;
          }
        },
      );
      return selectedVariant?.stock ?? 0;
    }
    return 0;
  }
}
