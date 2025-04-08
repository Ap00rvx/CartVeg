import 'package:cart_veg/bloc/cart/cart_bloc.dart';
import 'package:cart_veg/bloc/category_page/category_bloc.dart';
import 'package:cart_veg/locator.dart';
import 'package:cart_veg/model/product_model.dart';
import 'package:cart_veg/service/authentication_service.dart';
import 'package:cart_veg/widgets/button_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

class CategoryContent extends StatefulWidget {
  const CategoryContent({super.key});

  @override
  State<CategoryContent> createState() => _CategoryContentState();
}

class _CategoryContentState extends State<CategoryContent> {
  final user = locator.get<AuthenticationService>().user;
  final ScrollController _scrollController = ScrollController();
  late CategoryPageBloc _categoryPageBloc;

  @override
  void initState() {
    super.initState();
    _categoryPageBloc = locator<CategoryPageBloc>()..add(FetchInitialData());
    _scrollController.addListener(_onScroll);
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
      final state = _categoryPageBloc.state;
      if (state is CategoryLoaded && state.hasMoreData && !state.isLoading) {
        _categoryPageBloc.add(LoadMoreProducts(state.selectedCategory));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoryPageBloc>.value(
      value: _categoryPageBloc,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          // ... (AppBar code remains unchanged)
          backgroundColor: Colors.white,
          toolbarHeight: 80,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back,',
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
              Text(
                user?.name ?? 'Guest',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          actions: [
            CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.4),
              radius: 23,
              child: Text(
                user?.name?.substring(0, 1).toUpperCase() ?? 'G',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            final currentState = _categoryPageBloc.state;
            String currentCategory = "Vegetable";
            if (currentState is CategoryLoaded) {
              currentCategory = currentState.selectedCategory;
            }
            _categoryPageBloc.add(RefreshProducts(currentCategory));
            context.read<CartBloc>().add(CartStarted());
          },
          child: Column(
            children: [
              _buildSidebar(),
              Expanded(child: _buildProductSection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return BlocBuilder<CategoryPageBloc, CategoryState>(
      builder: (context, state) {
        return Container(
          height: 60,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: state.categories.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8.0),
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    final isSelected = state is CategoryLoaded &&
                        state.selectedCategory == category;
                    return ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          context
                              .read<CategoryPageBloc>()
                              .add(RefreshProducts(category));
                        }
                      },
                      selectedColor: Colors.green.withOpacity(0.2),
                      backgroundColor: Colors.grey[100],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.green : Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? Colors.green : Colors.grey,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildProductSection() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          BlocBuilder<CategoryPageBloc, CategoryState>(
            builder: (context, state) {
              if (state is CategoryInitial ||
                  (state is CategoryLoading && state.products.isEmpty)) {
                return _buildLoadingShimmer();
              } else if (state is CategoryLoading &&
                  state.products.isNotEmpty) {
                return _buildProductGrid(state.products, true, true);
              } else if (state is CategoryLoaded) {
                return _buildProductGrid(
                    state.products, state.hasMoreData, state.isLoading);
              } else if (state is CategoryError) {
                return _buildErrorState(state.error);
              }
              return const Center(child: Text("No products available."));
            },
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _buildProductGrid(
      List<Product> products, bool hasMore, bool isLoading) {
    if (products.isEmpty && !isLoading) {
      return SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                  height: 200, child: Lottie.asset("assets/empty.json")),
            ),
            const Text(
              "Seems like no Product is Available for this section :(",
              style: TextStyle(fontSize: 12),
            )
          ],
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length + (hasMore && isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == products.length && hasMore && isLoading) {
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
                  Text(
                    product.name,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Visibility(
                        visible: product.actualPrice != product.price,
                        child: Text(
                          "₹${product.actualPrice}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "₹${product.price}",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (product.stock - product.threshold <= 5)
                    const Text(
                      "Low Stock",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  BlocBuilder<CartBloc, CartState>(
                    builder: (context, state) {
                      if (state is CartLoaded) {
                        final inCart = state.cart.items
                            .any((item) => item.product.id == product.id);
                        if (inCart) {
                          final cartItem = state.cart.items.firstWhere(
                            (item) => item.product.id == product.id,
                          );
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
                                  child: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                              Text(
                                '${cartItem.quantity}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              InkWell(
                                onTap: () {
                                  if (product.stock - product.threshold <
                                      cartItem.quantity + 1) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Stock limit reached',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black),
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
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: product.stock - product.threshold <
                                            cartItem.quantity + 1
                                        ? Colors.grey
                                        : Colors.green,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
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
                              content: Text(
                                '${product.name} added to cart',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                              duration: const Duration(seconds: 1),
                              backgroundColor: Colors.green.shade100,
                            ),
                          );
                        },
                        style: greenButtonStyle.copyWith(
                          minimumSize: const WidgetStatePropertyAll(
                              Size(double.maxFinite, 40)),
                          foregroundColor:
                              const WidgetStatePropertyAll(Colors.white),
                        ),
                        child: const Text(
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
      itemCount: 6,
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
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final currentState = _categoryPageBloc.state;
              String currentCategory = "Vegetable";
              if (currentState is CategoryLoaded) {
                currentCategory = currentState.selectedCategory;
              }
              _categoryPageBloc.add(RefreshProducts(currentCategory));
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
