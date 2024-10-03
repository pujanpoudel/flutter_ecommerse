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
  var selectedSize = ''.obs;
  var selectedColor = ''.obs;
  var selectedQuantity = 1.obs;
  var selectedProducts = <Product>[].obs;
  final RxList<CartModel> cartItems = <CartModel>[].obs;
  final RxBool isSelectionMode = false.obs;
  final RxInt currentImageIndex = 0.obs;

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

  void updateCurrentImageIndex(int index) {
    currentImageIndex.value = index;
  }

  Future<void> saveCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final items = cartItems.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList('cartItems', items);
  }

  void addToCart(CartModel item) {
    final index = cartItems.indexWhere((element) =>
        element.id == item.id &&
        element.variant?.color == item.variant?.color &&
        element.variant?.size == item.variant?.size);

    if (index != -1) {
      cartItems[index].quantity += item.quantity;

      if (cartItems[index].variant != null &&
          cartItems[index].quantity > cartItems[index].variant!.stock) {
        cartItems[index].quantity = cartItems[index].variant!.stock;
      }
    } else {
      cartItems.add(item);
    }
    saveCartItems();
  }

  void removeFromCart(String productId) {
    cartItems.removeWhere((item) => item.id == productId);
    selectedItems.remove(productId);
    saveCartItems();
  }

  void clearCart() {
    cartItems.clear();
    saveCartItems();
  }

  void updateQuantity(String productId, int quantity,
      {List<String>? color, List<String>? size}) {
    bool listEquals(List<String>? list1, List<String>? list2) {
      if (list1 == null || list2 == null) return list1 == list2;
      if (list1.length != list2.length) return false;
      for (int i = 0; i < list1.length; i++) {
        if (list1[i] != list2[i]) return false;
      }
      return true;
    }

    final index = cartItems.indexWhere((item) =>
        item.id == productId &&
        item.variant != null &&
        listEquals(item.variant!.color, color) &&
        listEquals(item.variant!.size, size));

    if (index != -1) {
      final itemVariant = cartItems[index].variant;
      if (itemVariant != null) {
        if (quantity > itemVariant.stock) {
          quantity = itemVariant.stock;
        }
        itemVariant.quantity = quantity;
        if (itemVariant.quantity <= 0) {
          cartItems.removeAt(index);
          selectedItems.remove(productId);
        }

        saveCartItems();
      }
    }
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

  bool isInCart(String productId, {List<String>? color, List<String>? size}) {
    return cartItems.any((item) =>
        item.id == productId &&
        item.variant != null &&
        item.variant!.color == color &&
        item.variant!.size == size);
  }

  int getQuantity(String productId, {List<String>? color, List<String>? size}) {
    bool listEquals(List<String>? list1, List<String>? list2) {
      if (list1 == null || list2 == null) return list1 == list2;
      if (list1.length != list2.length) return false;
      for (int i = 0; i < list1.length; i++) {
        if (list1[i] != list2[i]) return false;
      }
      return true;
    }

    final item = cartItems.firstWhere(
      (item) =>
          item.id == productId &&
          item.variant != null &&
          listEquals(item.variant!.color, color) &&
          listEquals(item.variant!.size, size),
      orElse: () => CartModel(
        id: productId,
        name: '',
        description: '',
        variant: CartVariant(
          size: size ?? [''],
          color: color ?? [''],
          stock: 0,
        ),
        imageUrl: [],
        category: '',
        vendor: '',
        price: 0,
        quantity: 0,
      ),
    );
    return item.quantity;
  }

  CartVariant? getSelectedVariant(CartModel cartItem) {
    return cartItem.variant;
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
      Variant? selectedVariant = product.value!.variant?.firstWhereOrNull(
        (v) => v.size == selectedSize && v.color == selectedColor,
      );
      return selectedVariant?.stock ?? 0;
    }
    return 0;
  }
}
