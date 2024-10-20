import 'package:get/get.dart';
import 'package:quick_cart/models/product_model.dart';
import 'package:quick_cart/utils/app_constants.dart';

class ProductRepo extends GetxService {
  final RxList<Product> _products = <Product>[].obs;
  List<Product> get products => _products;
  final String baseUrlProduct = AppConstants.BASE_URL_PRODUCT;
  final RxList<Category> _categories = <Category>[].obs;
  List<Category> get categories => _categories;
  var isLoading = false.obs;
  var error = ''.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;

  Future<List<Product>> getProducts({int page = 1}) async {
    isLoading.value = true;
    error.value = '';
    List<Product> fetchedProducts = [];
    try {
      final response = await GetConnect().get(
        '$baseUrlProduct/get/products?page=$page',
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch products');
      }
      final jsonResponse = response.body;
      if (jsonResponse['success'] != true) {
        throw Exception(jsonResponse['message'] ?? 'Failed to fetch products');
      }
      final data = jsonResponse['data'];
      final List<dynamic> productsJson = data['data'];
      fetchedProducts = productsJson
          .map((productJson) => Product.fromJson(productJson))
          .toList();

      currentPage.value = page;
      totalPages.value = data['total_pages'];
      if (page == 1) {
        _products.assignAll(fetchedProducts);
      } else {
        _products.addAll(fetchedProducts);
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
    return fetchedProducts;
  }

  Future<List<Category>> getCategories() async {
    isLoading.value = true;
    error.value = '';
    List<Category> fetchedCategories = [];
    try {
      final response = await GetConnect().get(
        '$baseUrlProduct/get/categories',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch categories');
      }
      final jsonResponse = response.body;
      if (jsonResponse['success'] != true) {
        throw Exception(jsonResponse['message']);
      }

      final data = jsonResponse['data'];
      final List<dynamic> categoriesList = data['data'];
      fetchedCategories = categoriesList
          .map((categoryJson) => Category.fromJson(categoryJson))
          .toList();

      _categories.assignAll(fetchedCategories);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
    return fetchedCategories;
  }

  Future<List<Product>> getProductsByCategories(
      List<String> categoryIds) async {
    try {
      final categoryIdsString = categoryIds.join('&');

      final response = await GetConnect().get(
        '$baseUrlProduct/get/products?category=$categoryIdsString',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load products: ${response.statusText}');
      }

      final jsonResponse = response.body;
      if (jsonResponse['success'] != true) {
        throw Exception(jsonResponse['message'] ?? 'Failed to load products');
      }

      final data = jsonResponse['data'];
      if (data != null && data['data'] is List) {
        List<Product> products = (data['data'] as List)
            .map((productJson) => Product.fromJson(productJson))
            .toList();
        _products.assignAll(products);
        return products;
      } else {
        throw Exception('Invalid data format in the response');
      }
    } catch (e) {
      error.value = e.toString();
      return [];
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      final response = await GetConnect().get(
        '$baseUrlProduct/get/product/$id',
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch product details');
      }
      final productData = response.body['data'];
      return Product.fromJson(productData);
    } catch (e) {
      error.value = 'Failed to fetch product details: ${e.toString()}';
      return null;
    }
  }

  Future<void> loadMoreProducts() async {
    if (currentPage.value < totalPages.value && !isLoading.value) {
      await getProducts(page: currentPage.value + 1);
    }
  }

  Future<void> refreshProducts() async {
    currentPage.value = 1;
    await getProducts(page: 1);
  }
}
