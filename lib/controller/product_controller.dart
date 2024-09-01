import 'package:get/get.dart';
import 'package:quick_cart/repo/product_repo.dart';
import 'package:quick_cart/models/product_model.dart';

class ProductController extends GetxController {
  final ProductRepo productRepo;
  ProductController({required this.productRepo});

  List<Product> get products => productRepo.products;

  bool get isLoading => productRepo.isLoading.value;

  String get error => productRepo.error.value;

  int get currentPage => productRepo.currentPage.value;

  int get totalPages => productRepo.totalPages.value;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts({int page = 1}) async {
    await productRepo.getProducts(page: page);
  }

  Future<Product?> getProductById(String id) async {
    return await productRepo.getProductById(id);
  }

  void loadMoreProducts() {
    if (currentPage < totalPages && !isLoading) {
      productRepo.loadMoreProducts();
    }
  }

  Future<void> refreshProducts() async {
    await productRepo.refreshProducts();
  }
}
