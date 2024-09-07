import 'package:get/get.dart';
import 'package:quick_cart/repo/product_repo.dart';
import 'package:quick_cart/models/product_model.dart';

class ProductController extends GetxController {
  final ProductRepo productRepo;
  ProductController({required this.productRepo});

  // Existing observables
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  

  // New observables for categories
  final RxList<Category> categories = <Category>[].obs;
  final RxBool isCategoriesLoading = false.obs;
  final RxString categoriesError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getProducts();
    fetchCategories();
  }

  // Fetch products with error handling and loading state
  Future<void> getProducts({int page = 1}) async {
    try {
      isLoading.value = true;
      error.value = ''; // Clear previous errors

      List<Product> getProducts = await productRepo.getProducts(page: page);
      products.assignAll(getProducts); // Replace current product list
      currentPage.value = productRepo.currentPage.value;
      totalPages.value = productRepo.totalPages.value;
    } catch (e) {
      error.value = 'Failed to load products'; // Handle errors
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
      getProducts(page: currentPage.value + 1); // Fetch next page
    }
  }

  // Refresh products by re-fetching the first page
  Future<void> refreshProducts() async {
    currentPage.value = 1;
    products.clear();
    await getProducts(page: 1); // Re-fetch products for the first page
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
      // Trigger update
      categories.refresh();
      // You might want to fetch products based on selected categories here
      // fetchProductsByCategories();
    }
  }

  // Refresh categories
  Future<void> refreshCategories() async {
    categories.clear();
    await fetchCategories();
  }
}
