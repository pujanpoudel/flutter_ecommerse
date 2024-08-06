import 'package:get/get.dart';
import 'package:quick_cart/models/product_model.dart';
import '../repo/product_repo.dart';

class ProductController extends GetxController {
  final ProductRepo productRepo;
  
  var isLoading = true.obs;
  var products = <Product>[].obs;
  var errorMessage = ''.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;

  ProductController({required this.productRepo});

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await productRepo.fetchProducts();

      if (response['success'] == true) {
        final data = response['data'];
        totalPages.value = data['total_pages'];
        currentPage.value = data['current_page'];

        final List<dynamic> productList = data['data'];
        products.value = productList.map((json) => Product.fromJson(json)).toList();
      } else {
        errorMessage.value = response['message'] ?? 'Failed to load products';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load products. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void refreshProducts() {
    currentPage.value = 1;
    fetchProducts();
  }

  // Add more methods as needed, e.g., for pagination, filtering, etc.
}