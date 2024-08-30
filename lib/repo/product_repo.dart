import 'package:get/get.dart';
import 'package:quick_cart/api/api_client.dart';
import 'package:quick_cart/models/product_model.dart';
import 'package:quick_cart/models/response_model.dart';

class ProductRepo extends GetxController {
  final ApiClient apiClient;

  ProductRepo({required this.apiClient});

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

  Future<void> fetchProducts({int page = 1}) async {
    _isLoading.value = true;
    _error.value = '';

    try {
      final Response response = await apiClient.getData('/products?page=$page');
      if (response.statusCode == 200) {
        final productResponse = ProductResponse.fromJson(response.body);
        if (productResponse.success) {
          _currentPage.value = page;
          _totalPages.value = productResponse.data.totalPages; // Assuming this field exists
          if (page == 1) {
            _products.assignAll(productResponse.data.data);
          } else {
            _products.addAll(productResponse.data.data);
          }
        } else {
          _error.value = productResponse.message;
        }
      } else {
        _error.value = response.statusText ?? 'Failed to fetch products';
      }
    } catch (e) {
      _error.value = 'Failed to fetch products: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      final Response response = await apiClient.getData('/products/$id');
      if (response.statusCode == 200) {
        final productData = response.body['data'];
        return Product.fromJson(productData);
      } else {
        _error.value = response.statusText ?? 'Failed to fetch product details';
        return null;
      }
    } catch (e) {
      _error.value = 'Failed to fetch product details: ${e.toString()}';
      return null;
    }
  }

  Future<ResponseModel> addProduct(Product product) async {
    try {
      final Response response = await apiClient.postData('/products', product.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        final productResponse = ProductResponse.fromJson(response.body);
        if (productResponse.success) {
          _products.add(productResponse.data.data[0]);
          return ResponseModel(true, 'Product added successfully');
        } else {
          return ResponseModel(false, 'Failed to add product: ${productResponse.message}');
        }
      } else {
        return ResponseModel(false, response.statusText ?? 'Failed to add product');
      }
    } catch (e) {
      return ResponseModel(false, 'Failed to add product: ${e.toString()}');
    }
  }

  Future<ResponseModel> updateProduct(Product product) async {
    try {
      final Response response = await apiClient.postData('/products/${product.id}', product.toJson());
      if (response.statusCode == 200) {
        final productResponse = ProductResponse.fromJson(response.body);
        if (productResponse.success) {
          final index = _products.indexWhere((p) => p.id == product.id);
          if (index != -1) {
            _products[index] = productResponse.data.data[0];
            return ResponseModel(true, 'Product updated successfully');
          } else {
            return ResponseModel(false, 'Product not found');
          }
        } else {
          return ResponseModel(false, 'Failed to update product: ${productResponse.message}');
        }
      } else {
        return ResponseModel(false, response.statusText ?? 'Failed to update product');
      }
    } catch (e) {
      return ResponseModel(false, 'Failed to update product: ${e.toString()}');
    }
  }

  Future<ResponseModel> deleteProduct(String id) async {
    try {
      final Response response = await apiClient.getData('/products/$id/delete');
      if (response.statusCode == 200) {
        final productResponse = ProductResponse.fromJson(response.body);
        if (productResponse.success) {
          _products.removeWhere((p) => p.id == id);
          return ResponseModel(true, 'Product deleted successfully');
        } else {
          return ResponseModel(false, 'Failed to delete product: ${productResponse.message}');
        }
      } else {
        return ResponseModel(false, response.statusText ?? 'Failed to delete product');
      }
    } catch (e) {
      return ResponseModel(false, 'Failed to delete product: ${e.toString()}');
    }
  }
}