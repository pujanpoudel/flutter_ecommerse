import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quick_cart/controller/product_controller.dart';
import 'package:quick_cart/utils/bottom_nav_bar_widget.dart';
import 'package:quick_cart/utils/skeleton_loader_widget.dart';
import 'package:quick_cart/models/product_model.dart';
import 'package:quick_cart/view/product/product_detail_page.dart';
import '../../utils/colors.dart';

class HomePage extends StatelessWidget {
  final ProductController productController = Get.find<ProductController>();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 0,
      body: Scaffold(
        appBar: _buildAppBar(),
        body: RefreshIndicator(
          onRefresh: productController.refreshProducts,
          child: Obx(() {
            if (productController.isLoading &&
                productController.products.isEmpty) {
              return _buildSkeletonLoader();
            } else if (productController.error.isNotEmpty) {
              return _buildErrorWidget();
            } else {
              return _buildProductGrid();
            }
          }),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.mainColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          SvgPicture.asset(
            'assets/delivery_icon.svg',
            // width: 40,
            // height: 40,
            height: 70,
          ),
          const SizedBox(width: 10),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () {}),
      ],
    );
  }

  Widget _buildSkeletonLoader() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SkeletonLoader(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(
                      width: double.infinity,
                      height: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    SkeletonLoader(
                      width: 80,
                      height: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(productController.error, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: productController.fetchProducts,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo is ScrollEndNotification &&
            scrollInfo.metrics.extentAfter == 0 &&
            productController.currentPage < productController.totalPages) {
          productController.loadMoreProducts();
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: productController.products.length +
            (productController.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < productController.products.length) {
            return _buildProductCard(productController.products[index]);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => Get.to(() => ProductDetailPage(productId: product.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.network(
                  product.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.mainColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(Product product) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(product.name,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('\$${product.price.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, color: AppColors.mainColor)),
            const SizedBox(height: 16),
            Text(product.description),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _showEditProductDialog(product),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainColor),
                  child: const Text('Edit'),
                ),
                ElevatedButton(
                  onPressed: () => _deleteProduct(product),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add New Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newProduct = Product(
                id: DateTime.now().toString(), // Temporary ID
                name: nameController.text,
                price: double.tryParse(priceController.text) ?? 0,
                description: descriptionController.text,
                image: 'https://via.placeholder.com/150', // Placeholder image
                category: Category(
                    id: '1', name: 'Default', description: 'Default Category'),
                stock: 0,
                status: true,
                vendor: Vendor(id: '1', storeName: 'Default Store'),
                type: ProductType(
                    id: '1', name: 'Default', description: 'Default Type'),
              );
              productController.addProduct(newProduct);
              Get.back();
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.mainColor),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(Product product) {
    final nameController = TextEditingController(text: product.name);
    final priceController =
        TextEditingController(text: product.price.toString());
    final descriptionController =
        TextEditingController(text: product.description);

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedProduct = Product(
                id: product.id,
                name: nameController.text,
                price: double.tryParse(priceController.text) ?? product.price,
                description: descriptionController.text,
                image: product.image,
                category: product.category,
                stock: product.stock,
                status: product.status,
                vendor: product.vendor,
                type: product.type,
              );
              productController.updateProduct(updatedProduct);
              Get.back();
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.mainColor),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(Product product) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              productController.deleteProduct(product.id);
              Get.back(closeOverlays: true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
