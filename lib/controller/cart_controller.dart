import 'dart:convert';
import 'package:get/get.dart';
import 'package:quick_cart/models/cart_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartController extends GetxController {
  RxList<CartModel> cartItems = <CartModel>[].obs;

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
      element.color == item.color && 
      element.size == item.size
    );
    if (index != -1) {
      cartItems[index].quantity++;
    } else {
      cartItems.add(item);
    }
    saveCartItems();
  }

  void removeFromCart(String productId, {String? color, String? size}) {
    cartItems.removeWhere((item) => 
      item.id == productId && 
      item.color == color && 
      item.size == size
    );
    saveCartItems();
  }

  void updateQuantity(String productId, int quantity, {String? color, String? size}) {
    final index = cartItems.indexWhere((item) => 
      item.id == productId && 
      item.color == color && 
      item.size == size
    );
    if (index != -1) {
      cartItems[index].quantity = quantity;
      if (quantity <= 0) {
        cartItems.removeAt(index);
      }
      saveCartItems();
    }
  }

  bool isInCart(String productId, {String? color, String? size}) {
    return cartItems.any((item) => 
      item.id == productId && 
      item.color == color && 
      item.size == size
    );
  }

  int getQuantity(String productId, {String? color, String? size}) {
    final item = cartItems.firstWhere(
      (item) => 
        item.id == productId && 
        item.color == color && 
        item.size == size,
      orElse: () => CartModel(
        id: productId,
        name: '',
        color: color,
        size: size,
        imageUrl: '',
        price: 0,
        quantity: 0,
      )
    );
    return item.quantity;
  }

  double get totalAmount =>
      cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
}