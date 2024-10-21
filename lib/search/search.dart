import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_cart/models/product_model.dart';
import 'package:quick_cart/repo/product_repo.dart';
import 'package:quick_cart/utils/app_constants.dart';
import 'package:quick_cart/view/product/product_detail_page.dart';

class SearchController extends GetxController {
  final ProductRepo productRepo = Get.find<ProductRepo>();
  var searchResults = <Product>[].obs;
  var isLoading = false.obs;
  var currentPage = 1.obs;
  final int pageSize = 20;

  Future<void> performSearch(String query, {bool resetPage = true}) async {
    if (resetPage) {
      currentPage.value = 1;
      searchResults.clear();
    }
    isLoading.value = true;
    try {
      const String baseUrl = AppConstants.BASE_URL;
      final response = await GetConnect().post('$baseUrl/search',
          {"search": query, "page": currentPage.value, "page_size": pageSize});

      if (response.status.hasError) {
        throw Exception(
            'Failed to load search results: ${response.statusText}');
      }

      final jsonResponse = response.body;
      if (jsonResponse['success'] != true) {
        throw Exception(
            jsonResponse['message'] ?? 'Failed to fetch search results');
      }

      final data = jsonResponse['data'];
      final List<dynamic> productsJson = data['data'];
      final newProducts =
          productsJson.map((item) => Product.fromJson(item)).toList();

      searchResults.addAll(newProducts);
      currentPage.value++;
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void loadMoreResults(String query) {
    if (!isLoading.value) {
      performSearch(query, resetPage: false);
    }
  }
}

class SearchPage extends GetView<SearchController> {
  final searchController = Get.put(SearchController());
  final TextEditingController _searchTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  SearchPage({Key? key}) : super(key: key) {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        searchController.loadMoreResults(_searchTextController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Products'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchTextController,
              decoration: InputDecoration(
                hintText: 'Search for products...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => searchController
                      .performSearch(_searchTextController.text),
                ),
              ),
              onSubmitted: (value) => searchController.performSearch(value),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (searchController.isLoading.value &&
                  searchController.currentPage.value == 1) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                controller: _scrollController,
                itemCount: searchController.searchResults.length + 1,
                itemBuilder: (context, index) {
                  if (index == searchController.searchResults.length) {
                    return Obx(() => searchController.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : const SizedBox.shrink());
                  }
                  final product = searchController.searchResults[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: product.image.isNotEmpty
                          ? Image.network(
                              product.image[0],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image_not_supported),
                      title: Text(product.name),
                      subtitle: Text(product.description ?? ''),
                      trailing: Text('\$${product.price.toStringAsFixed(2)}'),
                      onTap: () {
                        Get.to(() => ProductDetailPage(productId: product.id));
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
