import 'package:carousel_slider/carousel_slider.dart';
import 'package:cart_veg/bloc/auth/authentication_bloc_bloc.dart';
import 'package:cart_veg/bloc/cart/cart_bloc.dart';
import 'package:cart_veg/bloc/product/product_bloc.dart';
import 'package:cart_veg/bloc/productIds/product_ids_bloc.dart';
import 'package:cart_veg/locator.dart';
import 'package:cart_veg/model/verify_otp_model.dart';
import 'package:cart_veg/pages/home/widgets/search_bar.dart';
import 'package:cart_veg/service/authentication_service.dart';
import 'package:cart_veg/model/product_model.dart';
import 'package:cart_veg/service/common_service.dart';
import 'package:cart_veg/service/location_service.dart';
import 'package:cart_veg/widgets/button_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:palette_generator/palette_generator.dart';

// import 'caousel_slider/carousel_slider.dart';
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final user = locator.get<AuthenticationService>().user;
  final ScrollController _scrollController = ScrollController();
  late ProductBloc _productBloc;
  late CartBloc _cartBloc;
  final List<String> imagePaths = [
    // "assets/images/flyer1.jpg",
    "assets/images/flyer2.png",
    "assets/images/fly.png",
    "assets/images/image.png",
  ];

  // Color variables for UI
  Color _appBarColor = Colors.green.shade100; // Default color
  Color _searchBarColor = Colors.green.shade300; // Default color
  bool _colorsLoaded = false;
  final location = locator.get<LocationService>().longitude;

  @override
  void initState() {
    super.initState();
    print(location);
    _productBloc = locator<ProductBloc>()
      ..add(const LoadProducts(category: ""));
    _cartBloc = locator<CartBloc>()..add(CartStarted());
    _scrollController.addListener(_onScroll);
    _extractColorsFromFlyer();
  }

  // Extract colors from flyer image
  Future<void> _extractColorsFromFlyer() async {
    try {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        const AssetImage("assets/images/flyer.jpg"),
        size: const Size(200, 100),
        maximumColorCount: 20,
      );

      final Color appBarColor = paletteGenerator.dominantColor?.color ??
          paletteGenerator.vibrantColor?.color ??
          Colors.green.shade100;

      final Color searchBarColor = paletteGenerator.lightVibrantColor?.color ??
          paletteGenerator.mutedColor?.color ??
          appBarColor.withOpacity(0.7);

      setState(() {
        _appBarColor = appBarColor;
        _searchBarColor = searchBarColor;
        _colorsLoaded = true;
      });
    } catch (e) {
      print("Error extracting colors: $e");
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = _productBloc.state;
      if (state is ProductsLoaded && state.hasMore && !state.isLoadingMore) {
        print(
            "Triggering LoadMoreProducts at Scroll Position: ${_scrollController.position.pixels}");
        _productBloc.add(const LoadMoreProducts(category: ""));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductBloc>.value(value: _productBloc),
      ],
      child: BlocBuilder<AuthenticationBlocBloc, AuthenticationBlocState>(
        builder: (context, state) {
          if (state is AuthenticationBlocLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }
          if (state is AuthenticationBlocFailure) {
            return Center(
              child: Text(
                state.errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }
          if (state is UserDetailsSuccess) {
            return Scaffold(
              backgroundColor: Colors.grey.shade50,
              appBar: AppBar(
                backgroundColor: _appBarColor,
                toolbarHeight: 80,
                elevation: 2,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        fontSize: 16,
                        color: _colorsLoaded
                            ? _contrastingTextColor(_appBarColor)
                            : Colors.green,
                      ),
                    ),
                    Text(
                      user?.name ?? 'Guest',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _colorsLoaded
                            ? _contrastingTextColor(_appBarColor)
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
                actions: [
                  CircleAvatar(
                    backgroundColor: _colorsLoaded
                        ? _searchBarColor
                        : Colors.green.withOpacity(0.4),
                    radius: 20,
                    child: Text(
                      user?.name?.substring(0, 1).toUpperCase() ?? 'G',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _colorsLoaded
                            ? _contrastingTextColor(_searchBarColor)
                            : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  _productBloc.add(const LoadProducts(category: ""));
                  context.read<ProductIdsBloc>().add(ProductIdsFetchEvent());
                  _cartBloc.add(CartStarted());
                },
                color: Colors.green,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Search Bar and Flyer
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _appBarColor,
                              _appBarColor,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          // borderRadius: const BorderRadius.only(
                          //   bottomLeft: Radius.circular(30),
                          //   bottomRight: Radius.circular(30),
                          // ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: ProductSearchBar(),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  "assets/images/flyer.jpg",
                                  fit: BoxFit.cover,
                                  height: 180,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      // const SizedBox(height: 24),
                      // Category-based Product Sections
                      BlocBuilder<ProductBloc, ProductState>(
                        builder: (context, state) {
                          if (state is ProductInitial ||
                              state is ProductLoading) {
                            return _buildLoadingShimmer();
                          } else if (state is ProductsLoaded) {
                            return _buildCategorySections(state.products,
                                state.hasMore, state.isLoadingMore);
                          } else if (state is ProductError) {
                            return _buildErrorState(state.message);
                          }
                          return const Center(child: Text('Unexpected state'));
                        },
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        },
      ),
    );
  }

  // Helper method to determine contrasting text color
  Color _contrastingTextColor(Color backgroundColor) {
    double luminance = (0.299 * backgroundColor.red +
            0.587 * backgroundColor.green +
            0.114 * backgroundColor.blue) /
        255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  List<Product> _salesProducts(List<Product> products) {
    // Filter products that are on sale (mock implementation, adjust based on your data)
    return products
        .where((product) => product.details.actualPrice < product.details.price)
        .toList();
  }

  final displayCategories = locator
      .get<CommonService>()
      .categoriesResponse
      ?.categories
      .where((e) => e.image != "")
      .toList();

  // Group products by category (mock implementation, adjust based on your data)
  Map<String, List<Product>> _groupProductsByCategory(List<Product> products) {
    // Fetch categories from CommonService, fallback to default list
    final categories = locator
            .get<CommonService>()
            .categoriesResponse
            ?.categories
            .map((e) => e.name)
            .toList() ??
        ["Fruit", "Vegetable", "Dairy", "Snacks", "Beverages", "Bakery"];

    final Map<String, List<Product>> grouped = {};

    // Group products by matching their category field
    for (var category in categories) {
      grouped[category] = products
          .where(
              (p) => p.details.category.toLowerCase() == category.toLowerCase())
          .toList();
    }

    // Add products that don't belong to any defined category to 'Others'
    final others = products
        .where((p) => !categories.contains(p.details.category))
        .toList();
    if (others.isNotEmpty) {
      grouped['Others'] = others;
    }
    // Remove empty categories
    grouped.removeWhere((key, value) => value.isEmpty);

    return grouped;
  }

  // Build category sections with horizontal scrolling
  Widget _buildCategorySections(
      List<Product> products, bool hasMore, bool isLoadingMore) {
    final groupedProducts = _groupProductsByCategory(products);
    final categoryKeys = groupedProducts.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //display sale

        if (_salesProducts(products).isNotEmpty)
          Container(
            decoration: BoxDecoration(
              // color: Colors.green.shade50,

              gradient: LinearGradient(
                colors: [
                  _appBarColor,
                  Colors.green.shade200,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Great Discounts",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _contrastingTextColor(_appBarColor),
                          )),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      itemCount: _salesProducts(products).length,
                      itemBuilder: (context, index) {
                        final product = _salesProducts(products)[index];
                        return Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Stack(
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                          color: Colors.green.shade900,
                                          width: 2)),
                                  child: _buildProductCard(product)),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "₹${product.details.price - product.details.actualPrice} off",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

        for (int i = 0; i < categoryKeys.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Products in " + categoryKeys[i],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 280,
            child: ListView.builder(
              // shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: groupedProducts[categoryKeys[i]]!.length,
              itemBuilder: (context, index) {
                final product = groupedProducts[categoryKeys[i]]![index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildProductCard(product),
                );
              },
            ),
          ),
          // Add flyer every 2 categories
          if (i % 2 == 1 && i < categoryKeys.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: _buildFlyerBanner(),
            ),

          // add a text message after every 4 categories and only once
          if (i == categoryKeys.length - 3)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: ClipRRect(
                // color: Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 180,
                    autoPlay: true, // Enable auto-play for the carousel
                    autoPlayInterval: const Duration(seconds: 3),
                    enlargeCenterPage:
                        true, // Slightly enlarge the center image
                    viewportFraction: 1.0, // Full-width images
                    aspectRatio: 16 / 9,
                  ),
                  items: imagePaths.map((imagePath) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 180,
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
        if (hasMore)
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildLoadingIndicator(),
          ),
      ],
    );
  }

  // Build modern product card
  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        print("Product tapped: ${product.productId}");
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  product.details.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  // height: 140,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.details.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    product.details.unit,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "₹${product.details.price}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (product.details.actualPrice != product.details.price)
                        Text(
                          "₹${product.details.actualPrice}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  if (product.quantity - product.threshold <= 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "Only ${product.quantity - product.threshold} left",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  BlocBuilder<CartBloc, CartState>(
                    builder: (context, state) {
                      if (state is CartLoaded) {
                        final inCart = state.cart.items.any((item) =>
                            item.product.productId == product.productId);

                        if (inCart) {
                          final cartItem = state.cart.items.firstWhere((item) =>
                              item.product.productId == product.productId);

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  context
                                      .read<CartBloc>()
                                      .add(CartItemRemoved(product.productId));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                              Text(
                                '${cartItem.quantity}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (product.quantity - product.threshold <
                                      cartItem.quantity + 1) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Stock limit reached',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        duration: const Duration(seconds: 1),
                                        backgroundColor: Colors.red.shade100,
                                      ),
                                    );
                                    return;
                                  }
                                  context
                                      .read<CartBloc>()
                                      .add(CartItemAdded(product));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color:
                                        product.quantity - product.threshold <
                                                cartItem.quantity + 1
                                            ? Colors.grey
                                            : Colors.green,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      }
                      return ElevatedButton(
                        onPressed: () {
                          context.read<CartBloc>().add(CartItemAdded(product));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${product.details.name} added to cart',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              duration: const Duration(seconds: 1),
                              backgroundColor: Colors.green.shade100,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Add to Cart",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build promotional flyer banner
  Widget _buildFlyerBanner() {
    final banners = [
      "assets/images/flyer.jpg",
      "assets/images/flyer2.png",
      "assets/images/image.png",
      "assets/images/fly.png",
    ];
    final now = DateTime.now().microsecondsSinceEpoch % banners.length;

    return Container(
      height: 160,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: Image.asset(
          banners[now],
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Build shimmer loading for category sections
  Widget _buildLoadingShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < 3; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.white,
              child: Container(
                width: 150,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.white,
                    child: Container(
                      width: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 14,
                                  width: 100,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 14,
                                  width: 60,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 36,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (i < 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.white,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  // Build loading indicator for pagination
  Widget _buildLoadingIndicator() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      child: Container(
        height: 280,
        width: 160,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: 100,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 60,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 36,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
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

  // Build error state
  Widget _buildErrorState(String message) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.withOpacity(0.8),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _productBloc.add(const LoadProducts(category: ""));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _colorsLoaded ? _appBarColor : Colors.green,
                foregroundColor: _colorsLoaded
                    ? _contrastingTextColor(_appBarColor)
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
