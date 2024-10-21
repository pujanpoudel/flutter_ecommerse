import 'dart:convert';

import 'package:get/get.dart';
import 'package:quick_cart/models/cart_model.dart';
import 'package:quick_cart/repo/product_repo.dart';
import 'package:quick_cart/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductController extends GetxController {
  final ProductRepo productRepo;
  ProductController({required this.productRepo});
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  RxList<Category> categories = <Category>[].obs;
  final RxBool isCategoriesLoading = false.obs;
  final RxString categoriesError = ''.obs;
  RxList<Category> selectedCategories = RxList<Category>([]);
  final Rx<String> selectedColor = ''.obs;
  final Rx<String> selectedSize = ''.obs;
  var selectedQuantity = 1.obs;
  var showFullDescription = false.obs;
  var product = Rxn<Product>();
  final RxList<CartModel> cartItems = <CartModel>[].obs;
  final RxList<Product> favoriteProducts = <Product>[].obs;
  final RxList<Product> selectedProducts = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    getProducts();
    getCategories();
    loadFavorites();
  }

  Future<void> getProducts({int page = 1}) async {
    try {
      isLoading.value = true;
      error.value = '';
      List<Product> newProducts = await productRepo.getProducts(page: page);
      if (page == 1) {
        products.assignAll(newProducts);
      } else {
        products.addAll(newProducts);
      }
      currentPage.value = productRepo.currentPage.value;
      totalPages.value = productRepo.totalPages.value;
    } catch (e) {
      error.value = 'Failed to load products: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      return await productRepo.getProductById(id);
    } catch (e) {
      error.value = 'Failed to load product details';
      return null;
    }
  }

  void loadMoreProducts() async {
    if (currentPage.value < totalPages.value && !isLoading.value) {
      await getProducts(page: currentPage.value + 1);
    }
  }

  Future<void> refreshProducts() async {
    currentPage.value = 1;
    products.clear();
    await getProducts(page: 1);
    refreshCategories();
  }
  //categorites

  Future<void> getCategories() async {
    try {
      isCategoriesLoading.value = true;
      categoriesError.value = '';
      List<Category> fetchedCategories = await productRepo.getCategories();
      categories.assignAll(fetchedCategories);
    } catch (e) {
      categoriesError.value = 'Failed to load categories';
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  Future<void> refreshCategories() async {
    categories.clear();
    await getCategories();
  }

  Future<void> getProductsBySelectedCategories() async {
    if (selectedCategories.isEmpty) {
      await getProducts();
      return;
    }
    List<String> selectedCategoryIds =
        selectedCategories.map((category) => category.id.toString()).toList();
    try {
      isLoading.value = true;
      products.value =
          await productRepo.getProductsByCategories(selectedCategoryIds);
    } catch (e) {
      error.value = 'Failed to load products: $e';
    } finally {
      isLoading.value = false;
    }
  }

  //cart
  bool hasColorVariant() {
    return selectedColor.value.isNotEmpty;
  }

  bool hasSizeVariant() {
    return selectedSize.value.isNotEmpty;
  }

  void updateSelectedSize(String size) {
    selectedSize.value = size;
  }

  void updateSelectedColor(String color) {
    selectedColor.value = color;
  }

  void toggleDescription() {
    showFullDescription.value = !showFullDescription.value;
  }

  void increaseQuantity() {
    selectedQuantity.value++;
  }

  void decreaseQuantity() {
    if (selectedQuantity.value > 1) {
      selectedQuantity.value--;
    }
  }

//favorites
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJsonList = prefs.getStringList('favoriteProducts') ?? [];
    favoriteProducts.assignAll(
      favoritesJsonList.map((jsonString) {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        return Product.fromJson(json);
      }).toList(),
    );
  }

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJsonList = favoriteProducts
        .map((product) => jsonEncode(product.toJson()))
        .toList();
    await prefs.setStringList('favoriteProducts', favoritesJsonList);
  }

  Future<void> toggleFavorite(Product product) async {
    if (favoriteProducts.any((p) => p.id == product.id)) {
      favoriteProducts.removeWhere((p) => p.id == product.id);
    } else {
      favoriteProducts.add(product);
    }
    await saveFavorites();
  }

  bool isFavorite(String productId) {
    return favoriteProducts.any((product) => product.id == productId);
  }

  List<Product> getFavoriteProducts() {
    return products
        .where((product) => favoriteProducts.contains(product))
        .toList();
  }

  Future<void> removeFavorites(List<Product> products) async {
    for (var product in products) {
      favoriteProducts.removeWhere((p) => p.id == product.id);
    }
    await saveFavorites();
  }

  Future<void> addSelectedToFavorites(List<Product> selectedProducts) async {
    for (var product in selectedProducts) {
      if (!favoriteProducts.any((p) => p.id == product.id)) {
        favoriteProducts.add(product);
      }
    }
    await saveFavorites();
  }

  Future<CartModel?> getProductAsCartModel(String productId) async {
    try {
      final product = await getProductById(productId);
      if (product != null) {
        List<CartVariant>? productVariants = product.variant!.isNotEmpty
            ? product.variant
                ?.map((variant) => CartVariant(
                      color: variant.color,
                      size: variant.size,
                      stock: variant.stock,
                    ))
                .toList()
            : null;

        return CartModel(
          id: product.id,
          name: product.name,
          description: product.description,
          variant: productVariants,
          imageUrl: product.image,
          category: product.category.name,
          vendor: product.vendor.storeName,
          price: product.price,
          quantity: 1,
        );
      }
      return null;
    } catch (e) {
      error.value = 'Failed to load product as cart model: $e';
      return null;
    }
  }
}
