import 'package:get/get.dart';
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

      List<Product> getProducts = await productRepo.getProducts(page: page);
      products.assignAll(getProducts); 
      currentPage.value = productRepo.currentPage.value;
      totalPages.value = productRepo.totalPages.value;
    } catch (e) {
      error.value = 'Failed to load products'; 
    } finally {
      isLoading.value = false;
    }
  }

  // Get product by ID
  Future<Product?> getProductById(String id) async {
    try {
      return await productRepo.getProductById(id);
    } catch (e) {
      error.value = 'Failed to load product details';
      return null;
    }
  }

  // Load more products for pagination
  void loadMoreProducts() {
    if (currentPage.value < totalPages.value && !isLoading.value) {
      getProducts(page: currentPage.value + 1); 
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
      // You might want to fetch products based on selected categories here
      // fetchProductsByCategories();
    }
  }

  Future<void> refreshCategories() async {
    categories.clear();
    await fetchCategories();
  }
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favoriteProductIds') ?? [];
    _favoriteProductIds.value = favoriteIds.toSet();
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

  bool isFavorite(String productId) => _favoriteProductIds.contains(productId);
}
