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
  RxList<Category> categories = <Category>[].obs;
  final RxBool isCategoriesLoading = false.obs;
  final RxString categoriesError = ''.obs;
  RxList<Category> selectedCategories = RxList<Category>([]);
  var selectedSize = ''.obs;
  var selectedColor = ''.obs;
  var selectedQuantity = 1.obs;
  var showFullDescription = false.obs;
  var favoriteProductIds = <String>[].obs;
  var product = Rxn<Product>();
  final RxList<CartModel> cartItems = <CartModel>[].obs;
  var selectedProducts = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    getProducts();
    getCategories();
    loadFavorites();
  }

  Future<void> getProducts({int page = 1}) async {
    try {
      isLoading.value = true;
      error.value = '';

      List<Product> newProducts = await productRepo.getProducts(page: page);
      if (page == 1) {
        products.assignAll(newProducts);
      } else {
        products.addAll(newProducts);
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
    refreshCategories();
  }

  Future<void> getCategories() async {
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

  Future<void> refreshCategories() async {
    categories.clear();
    await getCategories();
  }

  Future<void> getProductsBySelectedCategories() async {
    if (selectedCategories.isEmpty) {
      await getProducts();
      return;
    }

    List<String> selectedCategoryIds =
        selectedCategories.map((category) => category.id.toString()).toList();
    try {
      isLoading.value = true;
      products.value =
          await productRepo.getProductsByCategories(selectedCategoryIds);
    } catch (e) {
      error.value = 'Failed to load products: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favoriteProductIds') ?? [];
    favoriteProductIds.assignAll(favoriteIds.toSet());
  }

  Future<void> toggleFavorite(String productId) async {
    if (favoriteProductIds.contains(productId)) {
      favoriteProductIds.remove(productId);
    } else {
      favoriteProductIds.add(productId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favoriteProductIds',
      favoriteProductIds.toList(),
    );
  }

  void updateSelectedSize(String size) {
    selectedSize.value = size;
  }

  void updateSelectedColor(String color) {
    selectedColor.value = color;
  }

  void toggleDescription() {
    showFullDescription.value = !showFullDescription.value;
  }

  void increaseQuantity() {
    selectedQuantity.value++;
  }

  void decreaseQuantity() {
    if (selectedQuantity.value > 1) {
      selectedQuantity.value--;
    }
  }

  bool isFavorite(String productId) => favoriteProductIds.contains(productId);

  Future<CartModel?> getProductAsCartModel(String productId) async {
    try {
      final product = await getProductById(productId);
      if (product != null) {
        List<CartVariant>? productVariants = product.variant!.isNotEmpty
            ? product.variant
                ?.map((variant) => CartVariant(
                      color: variant.color,
                      size: variant.size,
                      stock: variant.stock,
                    ))
                .toList()
            : null;

        return CartModel(
          id: product.id,
          name: product.name,
          description: product.description,
          variant: productVariants,
          imageUrl: product.image,
          category: product.category.name,
          vendor: product.vendor.storeName,
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
}
