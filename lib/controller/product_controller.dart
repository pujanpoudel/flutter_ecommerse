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
  final RxSet<String> _favoriteProductIds = <String>{}.obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxBool isCategoriesLoading = false.obs;
  final RxString categoriesError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getProducts();
    fetchCategories();
    loadFavorites();
  }

  Future<void> getProducts({int page = 1}) async {
    try {
      isLoading.value = true;
      error.value = '';

    
      List<Product> newProducts = await productRepo.getProducts(page: page);

      if (page == 1) {
        products
            .assignAll(newProducts);
      } else {
        products
            .addAll(newProducts);
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
  }

  Future<void> fetchCategories() async {
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

  void toggleCategorySelection(Category category) {
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      final updatedCategory =
          category.copyWith(isSelected: !category.isSelected);
      categories[index] = updatedCategory;
      categories.refresh();
    }
  }

  Future<void> refreshCategories() async {
    categories.clear();
    await fetchCategories();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favoriteProductIds') ?? [];
    _favoriteProductIds.assignAll(favoriteIds.toSet());
  }

  Future<void> toggleFavorite(String productId) async {
    if (_favoriteProductIds.contains(productId)) {
      _favoriteProductIds.remove(productId);
    } else {
      _favoriteProductIds.add(productId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favoriteProductIds',
      _favoriteProductIds.toList(),
    );
  }

  Future<CartModel?> getProductAsCartModel(String productId) async {
  try {
    final product = await getProductById(productId);
    if (product != null) {
      return CartModel(
        id: product.id,
        name: product.name,
        color: product.color?.hex,
        size: product.size?.toString(),
        imageUrl: product.image,
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

  bool isFavorite(String productId) => _favoriteProductIds.contains(productId);
}
