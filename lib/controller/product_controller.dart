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
      final response = await productRepo.fetchProducts(currentPage.value);

      if (response['success'] == true) {
        final data = response['data'];
        totalPages.value = data['total_pages'];
        currentPage.value = data['current_page'];

        final List<dynamic> productList = data['data'];
        if (currentPage.value == 1) {
          products.value = productList.map((json) => Product.fromJson(json)).toList();
        } else {
          products.addAll(productList.map((json) => Product.fromJson(json)).toList());
        }
      } else {
        errorMessage.value = response['message'] ?? 'Failed to load products';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load products. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProducts() async {
    currentPage.value = 1;
    await fetchProducts();
  }

  Future<void> loadMoreProducts() async {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      await fetchProducts();
    }
  }
}
