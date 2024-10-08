import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quick_cart/controller/auth_controller.dart';
import 'package:quick_cart/controller/product_controller.dart';
import 'package:quick_cart/utils/bottom_nav_bar_widget.dart';
import 'package:quick_cart/utils/skeleton_loader_widget.dart';
import 'package:quick_cart/models/product_model.dart';
import 'package:quick_cart/utils/colors.dart';
import 'package:quick_cart/view/product/product_detail_page.dart';
import 'package:quick_cart/view/profile/edit_profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final ProductController productController = Get.find<ProductController>();
  final AuthController controller = Get.find<AuthController>();
  final ScrollController scrollController = ScrollController();
  final CarouselSliderController carouselController =
      CarouselSliderController();
  int _current = 0;
  bool _isNavBarVisible = true;
  bool _showAllCategories = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productController.getCategories();
      productController.getProducts();
    });
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isNavBarVisible) setState(() => _isNavBarVisible = false);
    } else if (scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isNavBarVisible) setState(() => _isNavBarVisible = true);
    }
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!productController.isLoading.value &&
          productController.currentPage.value <
              productController.totalPages.value) {
        productController.loadMoreProducts();
      }
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
    productController.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 0,
      isNavBarVisible: _isNavBarVisible,
      body: RefreshIndicator(
        onRefresh: productController.refreshProducts,
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            const SliverToBoxAdapter(
              child: SizedBox(height: 15),
            ),
            SliverToBoxAdapter(child: _buildCarousel()),
            SliverToBoxAdapter(child: _buildCategorySection()),
            _buildProductGrid(productController),
            SliverToBoxAdapter(
              child: Obx(() {
                if (productController.isLoading.value) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: LoadingAnimationWidget.horizontalRotatingDots(
                          color: AppColors.mainColor, size: 50),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.mainColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ship to',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          child: Text(
                            controller.user.value.address ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          _isExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Icon(Icons.notifications_outlined, color: Colors.white),
            ],
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  Get.to(EditProfilePage());
                },
                child: const Text(
                  'Edit Address',
                  style: TextStyle(color: AppColors.mainColor),
                ),
              ),
            ),
          const SizedBox(height: 5),
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
                        Get.to(() => ProductDetailPage(productId: product.id));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.network(
                                  (product.image as List).isNotEmpty
                                      ? (product.image)[0]
                                      : product.image as String,
                                  fit: BoxFit.cover,
                                ),
                              ),
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
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        'NRP ${product.price.round()}',
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
                      ),
                    );
                  },
                );
              }).toList(),
              carouselController: carouselController,
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
                  onTap: () => carouselController.jumpToPage(entry.key),
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

  Widget _buildCategorySection() {
    return Obx(() {
      if (productController.isCategoriesLoading.value) {
        return Center(
            child: LoadingAnimationWidget.horizontalRotatingDots(
                color: AppColors.mainColor, size: 50));
      } else if (productController.categories.isEmpty) {
        return const Center(child: Text('No categories available'));
      } else {
        return RefreshIndicator(
          onRefresh: () async {
            await productController.refreshCategories();
          },
          child: _buildCategoryChips(),
        );
      }
    });
  }

  Widget _buildCategoryChips() {
    final displayedCategories = productController.categories.take(8).toList();
    return Column(
      children: [
        if (!_showAllCategories)
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: displayedCategories.length < 5
                  ? displayedCategories.length
                  : 6,
              itemBuilder: (context, index) {
                if (index == 5) {
                  return Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 16.0),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _showAllCategories = true;
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Show All',
                          style: TextStyle(
                            color: AppColors.mainColor,
                          ),
                        ),
                      ));
                }
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 16.0 : 8.0,
                    right: index == displayedCategories.length - 1 ? 16.0 : 0.0,
                  ),
                  child: _buildCategoryChip(displayedCategories[index]),
                );
              },
            ),
          ),
        if (_showAllCategories)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...productController.categories
                    .map((category) => _buildCategoryChip(category)),
                Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _showAllCategories = false;
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Collapse',
                        style: TextStyle(
                          color: AppColors.mainColor,
                        ),
                      ),
                    )),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryChip(Category category) {
    return Obx(() => ChoiceChip(
          label: Text(category.name),
          selected: productController.selectedCategories.contains(category),
          onSelected: (selected) {
            if (selected) {
              productController.selectedCategories.add(category);
            } else {
              productController.selectedCategories.remove(category);
            }
            productController.getProductsBySelectedCategories();
          },
          backgroundColor: AppColors.mainColor.withOpacity(0.1),
          selectedColor: AppColors.mainColor,
          labelStyle: TextStyle(
            color: productController.selectedCategories.contains(category)
                ? Colors.white
                : AppColors.mainColor,
          ),
        ));
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
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
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
            onPressed: () => productController.refreshProducts(),
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
        Get.to(() => ProductDetailPage(productId: product.id));
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
                          'NRP ${product.price.round()}',
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
                          productController.toggleFavorite(product);
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
