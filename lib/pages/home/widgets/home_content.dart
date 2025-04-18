import 'package:cart_veg/bloc/auth/authentication_bloc_bloc.dart';
import 'package:cart_veg/bloc/cart/cart_bloc.dart';
import 'package:cart_veg/bloc/product/product_bloc.dart';
import 'package:cart_veg/bloc/productIds/product_ids_bloc.dart';
import 'package:cart_veg/locator.dart';
import 'package:cart_veg/model/verify_otp_model.dart';
import 'package:cart_veg/pages/home/widgets/search_bar.dart';
import 'package:cart_veg/service/authentication_service.dart';
import 'package:cart_veg/model/product_model.dart';
import 'package:cart_veg/widgets/button_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:palette_generator/palette_generator.dart';

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

  // Add palette color variables
  Color _appBarColor = Colors.green.shade100; // Default color
  Color _searchBarColor = Colors.green.shade300; // Default color
  bool _colorsLoaded = false;

  @override
  void initState() {
    super.initState();
    _productBloc = locator<ProductBloc>()
      ..add(const LoadProducts(category: ""));
    _cartBloc = locator<CartBloc>()..add(CartStarted());
    _scrollController.addListener(_onScroll);
    // context.read<AuthenticationBlocBloc>().add(GetUserDetailsEvent());
    // Extract colors from the flyer image
    _extractColorsFromFlyer();
  }

  // Add method to extract colors
  Future<void> _extractColorsFromFlyer() async {
    try {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        const AssetImage("assets/images/flyer.jpg"),
        size: const Size(200, 100), // Smaller size for faster processing
        maximumColorCount: 20, // Get more colors to have better options
      );

      // Use dominant color for app bar if available, otherwise use vibrant or fallback
      final Color appBarColor = paletteGenerator.dominantColor?.color ??
          paletteGenerator.vibrantColor?.color ??
          Colors.green.shade100;

      // Use a complementary or lighter shade for search bar gradient
      final Color searchBarColor = paletteGenerator.lightVibrantColor?.color ??
          paletteGenerator.mutedColor?.color ??
          appBarColor.withOpacity(0.7);

      // Update state with extracted colors
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
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
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
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: _appBarColor, // Use extracted color
                toolbarHeight: 80,
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        fontSize: 20,
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
                    radius: 23,
                    child: Text(
                      user?.name?.substring(0, 1).toUpperCase() ?? 'G',
                      style: TextStyle(
                        color: _colorsLoaded
                            ? _contrastingTextColor(_searchBarColor)
                            : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  _productBloc.add(const LoadProducts(category: ""));
                  context.read<ProductIdsBloc>().add(ProductIdsFetchEvent());
                  _cartBloc.add(CartStarted());
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _appBarColor, // Use extracted app bar color
                              _appBarColor, // Use extracted app bar color
                              // Use extracted search bar color
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: ProductSearchBar(),
                            ),
                            SizedBox(height: 20),
                            Container(
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20)),
                                child: Image.asset(
                                  "assets/images/flyer.jpg",
                                  fit: BoxFit.fitWidth,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Flyer card with extracted background color

                            const Text(
                              "Popular Items",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            BlocBuilder<ProductBloc, ProductState>(
                              builder: (context, state) {
                                if (state is ProductInitial ||
                                    state is ProductLoading) {
                                  return _buildLoadingShimmer();
                                } else if (state is ProductsLoaded) {
                                  return _buildProductGrid(state.products,
                                      state.hasMore, state.isLoadingMore);
                                } else if (state is ProductError) {
                                  return _buildErrorState(state.message);
                                }
                                return const Center(
                                    child: Text('Unexpected state'));
                              },
                            ),
                            const SizedBox(height: 90),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          );
        },
      ),
    );
  }

  // Helper method to determine contrasting text color
  Color _contrastingTextColor(Color backgroundColor) {
    // Calculate relative luminance using the formula
    double luminance = (0.299 * backgroundColor.red +
            0.587 * backgroundColor.green +
            0.114 * backgroundColor.blue) /
        255;

    // Use white text on dark backgrounds, black text on light backgrounds
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Widget _buildProductGrid(
      List<Product> products, bool hasMore, bool isLoadingMore) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == products.length) {
          return _buildLoadingIndicator();
        }

        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        print("Product tapped: ${product.id}");
      },
      child: Card(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
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
                  Text(product.name,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Visibility(
                        visible: product.actualPrice != product.price,
                        child: Text("₹${product.actualPrice}",
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough)),
                      ),
                      const SizedBox(width: 4),
                      Text("₹${product.price}",
                          style: TextStyle(fontSize: 14, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (product.stock - product.threshold <= 5)
                    const Text("Low Stock",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.bold)),
                  BlocBuilder<CartBloc, CartState>(
                    builder: (context, state) {
                      if (state is CartLoaded) {
                        final inCart = state.cart.items
                            .any((item) => item.product.id == product.id);

                        if (inCart) {
                          final cartItem = state.cart.items.firstWhere(
                              (item) => item.product.id == product.id);

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  context
                                      .read<CartBloc>()
                                      .add(CartItemRemoved(product.id));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                              Text(
                                '${cartItem.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  if (product.stock - product.threshold <
                                      cartItem.quantity + 1) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            const Text('Stock limit reached',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                )),
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
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: product.stock - product.threshold <
                                            cartItem.quantity + 1
                                        ? Colors.grey
                                        : Colors.green,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 18,
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
                              content: Text('${product.name} added to cart',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  )),
                              duration: const Duration(seconds: 1),
                              backgroundColor: Colors.green.shade100,
                            ),
                          );
                        },
                        style: greenButtonStyle.copyWith(
                          minimumSize: const WidgetStatePropertyAll(
                              Size(double.maxFinite, 40)),
                          backgroundColor:
                              const WidgetStatePropertyAll(Colors.green),
                          foregroundColor:
                              const WidgetStatePropertyAll(Colors.white),
                        ),
                        child: Text(
                          "Add to Cart",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
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

  Widget _buildLoadingShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 6, // Show 6 shimmer placeholders
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
            baseColor: Colors.grey.shade100,
            highlightColor: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 20,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 20,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
            ));
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Shimmer.fromColors(
              baseColor: Colors.grey.shade100,
              highlightColor: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 20,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 20,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
              ))),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _productBloc.add(const LoadProducts(category: ""));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _colorsLoaded ? _appBarColor : Colors.blue,
              foregroundColor: _colorsLoaded
                  ? _contrastingTextColor(_appBarColor)
                  : Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
