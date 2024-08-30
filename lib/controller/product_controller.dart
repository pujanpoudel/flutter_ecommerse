import 'package:get/get.dart';
import 'package:quick_cart/models/product_model.dart';
import 'package:quick_cart/repo/product_repo.dart';

class ProductController extends GetxController {
  final ProductRepo productRepo;

  ProductController({required this.productRepo});

  final RxList<Product> _products = <Product>[].obs;
  List<Product> get products => _products;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxString _error = ''.obs;
  String get error => _error.value;

  final RxInt _currentPage = 1.obs;
  int get currentPage => _currentPage.value;

  final RxInt _totalPages = 1.obs;
  int get totalPages => _totalPages.value;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    _isLoading.value = true;
    _error.value = '';

    try {
      await productRepo.fetchProducts(page: 1);
      _products.assignAll(productRepo.products);
      _currentPage.value = 1; // Reset current page to 1 after fetching
      _totalPages.value = productRepo.totalPages; // Use totalPages from repo
    } catch (e) {
      _error.value = 'Failed to fetch products: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadMoreProducts() async {
    if (_isLoading.value || _currentPage.value >= _totalPages.value) {
      return; // Prevent loading more if already loading or no more pages
    }

    _isLoading.value = true;

    try {
      _currentPage.value++;
      await productRepo.fetchProducts(page: _currentPage.value);
      _products.addAll(productRepo.products);
    } catch (e) {
      _error.value = 'Failed to load more products: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshProducts() async {
    _isLoading.value = true;
    _error.value = '';

    try {
      await productRepo.fetchProducts(page: 1);
      _products.assignAll(productRepo.products);
      _currentPage.value = 1; // Reset current page to 1 after refreshing
      _totalPages.value = productRepo.totalPages; // Use totalPages from repo
    } catch (e) {
      _error.value = 'Failed to refresh products: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<Product?> getProductById(String id) async {
    return await productRepo.getProductById(id);
  }

  Future<void> addProduct(Product product) async {
    try {
      await productRepo.addProduct(product);
      _products.assignAll(productRepo.products);
    } catch (e) {
      _error.value = 'Failed to add product: ${e.toString()}';
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await productRepo.updateProduct(product);
      _products.assignAll(productRepo.products);
    } catch (e) {
      _error.value = 'Failed to update product: ${e.toString()}';
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await productRepo.deleteProduct(id);
      _products.assignAll(productRepo.products);
    } catch (e) {
      _error.value = 'Failed to delete product: ${e.toString()}';
    }
  }
}