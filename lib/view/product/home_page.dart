import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quick_cart/controller/product_controller.dart';
import 'package:quick_cart/utils/bottom_nav_bar_widget.dart';
import 'package:quick_cart/utils/skeleton_loader_widget.dart';
import 'package:quick_cart/models/product_model.dart';
import 'package:quick_cart/utils/colors.dart';
import 'package:quick_cart/view/product/product_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductController productController = Get.find<ProductController>();
  final ScrollController _scrollController = ScrollController();
  final CarouselController _carouselController = CarouselController();
  int _current = 0;
  bool _isNavBarVisible = true;
  bool _showAllCategories = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productController.fetchCategories();
      productController.getProducts();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isNavBarVisible) setState(() => _isNavBarVisible = false);
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isNavBarVisible) setState(() => _isNavBarVisible = true);
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!productController.isLoading.value &&
          productController.currentPage.value <
              productController.totalPages.value) {
        productController.loadMoreProducts();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
    productController.fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 0,
      isNavBarVisible: _isNavBarVisible,
      body: RefreshIndicator(
        onRefresh: productController.refreshProducts,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
            SliverToBoxAdapter(child: _buildCarousel()),
            SliverToBoxAdapter(child: _buildCategorySection(productController)),
            _buildProductGrid(productController),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      decoration: BoxDecoration(
          color: AppColors.mainColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Location',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 12)),
                  const Row(
                    children: [
                      Text('Parsa, Chitwan',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      Icon(Icons.arrow_drop_down, color: Colors.white),
                    ],
                  ),
                ],
              ),
              const Icon(Icons.notifications_outlined, color: Colors.white),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: const Icon(Icons.filter_list),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return Obx(() {
      if (productController.isLoading.value) {
        return Center(
            child: LoadingAnimationWidget.horizontalRotatingDots(
                color: AppColors.mainColor, size: 50));
      } else if (productController.products.isEmpty) {
        return const Center(child: Text('No products available'));
      } else {
        final carouselProducts = productController.products.take(5).toList();
        return Column(
          children: [
            CarouselSlider(
              items: carouselProducts.map((product) {
                return Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () {
                        Get.to(() => ProductDetailPage(
                            productId: product.id, product: product));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(
                              (product.image as List).isNotEmpty
                                  ? (product.image)[0]
                                  : product.image as String,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.8),
                                      Colors.transparent
                                    ],
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'NRP ${product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
              carouselController: _carouselController,
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 2.0,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: carouselProducts.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _carouselController.animateToPage(entry.key),
                  child: Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(_current == entry.key ? 0.9 : 0.4),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      }
    });
  }

  Widget _buildCategoryChip() {
    return Obx(() {
      if (productController.isCategoriesLoading.value) {
        return Center(
            child: LoadingAnimationWidget.horizontalRotatingDots(
                color: AppColors.mainColor, size: 50));
      } else if (productController.categories.isEmpty) {
        return const Center(child: Text('No categories available'));
      } else {
        final displayedCategories = _showAllCategories
            ? productController.categories
            : productController.categories.take(20).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Categories',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showAllCategories = !_showAllCategories;
                      });
                    },
                    child: Text(_showAllCategories ? 'Show Less' : 'See All'),
                  ),
                ],
              ),
            ),
            if (_showAllCategories)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: displayedCategories.map((category) {
                    return _buildCategoryChip();
                  }).toList(),
                ),
              )
            else
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: displayedCategories.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 16.0 : 8.0,
                        right: index == displayedCategories.length - 1
                            ? 16.0
                            : 0.0,
                      ),
                      child: _buildCategoryChip(),
                    );
                  },
                ),
              ),
          ],
        );
      }
    });
  }

  Widget _buildCategorySection(ProductController productController) {
    return Obx(() {
      if (productController.isCategoriesLoading.value) {
        return Center(
            child: LoadingAnimationWidget.horizontalRotatingDots(
                color: AppColors.mainColor, size: 50));
      } else if (productController.categoriesError.isNotEmpty) {
        return Center(child: Text(productController.categoriesError.value));
      } else if (productController.categories.isEmpty) {
        return const Center(child: Text('No categories available'));
      } else {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: productController.categories.map((category) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildCategoryChip(),
              );
            }).toList(),
          ),
        );
      }
    });
  }

  Widget _buildProductGrid(ProductController productController) {
    return Obx(() {
      if (productController.isLoading.value &&
          productController.products.isEmpty) {
        return SliverToBoxAdapter(child: _buildSkeletonLoader());
      } else if (productController.error.isNotEmpty) {
        return SliverToBoxAdapter(child: _buildErrorWidget());
      } else if (productController.products.isEmpty) {
        return const SliverToBoxAdapter(
          child: Center(child: Text('No products available')),
        );
      } else {
        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < productController.products.length) {
                  return _buildProductCard(
                    productController.products[index],
                    productController,
                  );
                }
                return null;
              },
              childCount: productController.products.length,
            ),
          ),
        );
      }
    });
  }

  Widget _buildSkeletonLoader() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
          Text(productController.error.value,
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => productController.getProducts(page: 1),
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

  Widget _buildProductCard(
      Product product, ProductController productController) {
    return GestureDetector(
      onTap: () {
        Get.to(
            () => ProductDetailPage(productId: product.id, product: product));
      },
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      aspectRatio: 1,
                      viewportFraction: 1,
                      enlargeCenterPage: false,
                      enableInfiniteScroll: product.image.length > 1,
                    ),
                    items: product.image.map((imageUrl) {
                      return Builder(
                        builder: (BuildContext context) {
                          return ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8)),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                    child:
                                        Icon(Icons.error, color: Colors.red));
                              },
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  if (product.image.length > 1)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: product.image.asMap().entries.map((entry) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          product.category.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'NRP${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(() => IconButton(
                        icon: Icon(
                          productController.isFavorite(product.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: productController.isFavorite(product.id)
                              ? Colors.red
                              : Colors.grey[600],
                        ),
                        onPressed: () {
                          productController.toggleFavorite(product.id);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        alignment: Alignment.topCenter,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
