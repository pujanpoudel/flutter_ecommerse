import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:quick_cart/models/product_model.dart';
import 'package:quick_cart/utils/app_constants.dart';

class ProductRepo extends GetxService {
  final RxList<Product> _products = <Product>[].obs;
  List<Product> get products => _products;

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
      final response = await http.get(
        Uri.parse('${AppConstants.BASE_URL_PRODUCT}/get/products?page=$page'),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch products');
      }
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final productResponse = ProductResponse.fromJson(jsonResponse);
      if (!productResponse.success) {
        throw Exception(productResponse.message);
      }
      currentPage.value = page;
      totalPages.value = productResponse.data.totalPages;
      if (page == 1) {
        _products.assignAll(productResponse.data.data);
      } else {
        _products.addAll(productResponse.data.data);
      }
      fetchedProducts = productResponse.data.data;
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
      final response = await http.get(
        Uri.parse('${AppConstants.BASE_URL_PRODUCT}/get/categories'),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch categories');
      }
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (!jsonResponse['success']) {
        throw Exception(jsonResponse['message']);
      }
      
      final data = jsonResponse['data'] as Map<String, dynamic>;
      final categoriesList = data['data'] as List;
      fetchedCategories = categoriesList.map((categoryJson) => Category.fromJson(categoryJson)).toList();
      
      _categories.assignAll(fetchedCategories);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
    return fetchedCategories;
  }


  Future<Product?> getProductById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.BASE_URL_PRODUCT}/get/product/$id'),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch product details');
      }
      final productData = json.decode(response.body)['data'];
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
