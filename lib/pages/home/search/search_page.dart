import 'package:cart_veg/bloc/cart/cart_bloc.dart';
import 'package:cart_veg/bloc/product/product_bloc.dart';
import 'package:cart_veg/locator.dart';
import 'package:cart_veg/model/product_model.dart';
import 'package:cart_veg/widgets/button_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cart_veg/bloc/search/search_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:badges/badges.dart' as badges;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch products when the page is loaded
    context.read<SearchBloc>().add(FetchSearchProducts());
    _searchController.addListener(_onSearchQueryChanged);
  }

  void _onSearchQueryChanged() {
    // Dispatch the search query event
    final query = _searchController.text;
    context.read<SearchBloc>().add(SearchQueryChanged(query));
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchQueryChanged);
    super.dispose();
  }

  int selected = 0;
  String selectedCategory = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new_rounded)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // **Search Bar with AutoFocus**
                TextField(
                  controller: _searchController,
                  cursorColor: Colors.green.shade900,
                  autofocus: true, // 👈 Auto-focus enabled
                  decoration: InputDecoration(
                    hintText: "Search products...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.green.shade900),
                    ),
                    prefixIcon: const Icon(Iconsax.search_favorite4),
                    suffixIcon: Visibility(
                      visible: _searchController.text.isNotEmpty,
                      child: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // **Search Results List**
                BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state is SearchLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is SearchError) {
                      return Center(child: Text('Error: ${state.message}'));
                    } else if (state is SearchLoaded) {
                      List<Product> products = state.products;
                      if (products.isEmpty) {
                        return const Center(child: Text('No results found.'));
                      }

                      // Extract unique categories from products
                      // Assuming Product has a 'category' property (adjust if it's different)
                      List<String> categories = products
                          .map((product) => product.category
                              .toLowerCase()) // Change 'category' to your actual property name
                          .toSet() // Remove duplicates
                          .toList();
                      categories = ["All", ...categories];

                      // Sort products by availability
                      if (selectedCategory == "" || selectedCategory == "All") {
                      } else {
                        products = products
                            .where((p) =>
                                p.category.toLowerCase() == selectedCategory)
                            .toList();
                      }
                      products.sort((a, b) => b.isAvailable == a.isAvailable
                          ? 0
                          : b.isAvailable
                              ? 1
                              : -1);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Chips Section
                          if (categories.isNotEmpty)
                            SizedBox(
                              height: 50,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  final category = categories[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: FilterChip(
                                      label: Text(category),
                                      selected: selected ==
                                          index, // You can add state management for selection
                                      onSelected: (bool value) {
                                        setState(() {
                                          selected = index;
                                          selectedCategory = category;
                                        });
                                      },
                                      backgroundColor: Colors.grey[200],
                                      selectedColor: Colors.green[100],
                                      checkmarkColor: Colors.green,
                                      labelStyle: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                            color: Colors.grey[300]!),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          // Product List
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return _buildProductCard(product);
                            },
                          ),
                          const SizedBox(height: 100),
                        ],
                      );
                    }

                    // If no products and the search input is empty
                    return _searchController.text.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Iconsax.search_favorite4,
                                    size: 50, color: Colors.grey),
                                SizedBox(height: 10),
                                Text(
                                  'Start typing to search for products.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : const Center(child: Text('No products available.'));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          int itemCount = 0;
          double totalAmount = 0.0;
          if (state is CartLoaded) {
            itemCount = state.cart.totalItems;
            totalAmount = state.cart.items.fold(
                0.0, (sum, item) => sum + item.totalPrice); // Calculate total
          }
          return (itemCount > 0)
              ? badges.Badge(
                  showBadge: true,
                  position: badges.BadgePosition.topEnd(top: 0, end: 3),
                  badgeStyle: const badges.BadgeStyle(
                    badgeColor: Colors.green,
                    padding: EdgeInsets.all(6),
                  ),
                  badgeContent: Text(
                    '$itemCount',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width -
                        32, // Full width with padding
                    height: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.green.shade900,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Iconsax.shopping_bag4,
                                      color: Colors.white, size: 30),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$itemCount Item${itemCount > 1 ? 's' : ''}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'View Cart',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                '₹${totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

Widget _buildProductCard(Product product) {
  return GestureDetector(
    onTap: () {
      print("Product tapped: ${product.id}");
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        enabled: product.isAvailable,
        tileColor: Colors.grey.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
        title: Card(
          color: Colors.grey.shade50,
          elevation: 0,
          margin: const EdgeInsets.symmetric(
              horizontal: 8.0, vertical: 4.0), // Added margin for spacing
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Row(
            // Changed Column to Row for list view format
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image section
              Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black38)),
                height: 100,
                width: 100,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(10)),
                  child: ColorFiltered(
                    colorFilter: product
                            .isAvailable // Assuming isAvailable is a boolean property
                        ? const ColorFilter.mode(Colors.transparent,
                            BlendMode.color) // No filter when available
                        : const ColorFilter.matrix(<double>[
                            // Grayscale filter when not available
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0, 0, 0, 1, 0,
                          ]),
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
              // Product details section
              product.isAvailable == false
                  ? Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12),
                            ),
                            Text(
                              "₹" + product.price.toString(),
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12),
                            ),
                            Text(
                              "Product is currently Not Available",
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: Padding(
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
                                        decoration: TextDecoration.lineThrough),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "₹${product.price}",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.green),
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
                                    fontWeight: FontWeight.bold),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                BlocBuilder<CartBloc, CartState>(
                                  builder: (context, state) {
                                    if (state is CartLoaded) {
                                      final inCart = state.cart.items.any(
                                          (item) =>
                                              item.product.id == product.id);

                                      if (inCart) {
                                        final cartItem = state.cart.items
                                            .firstWhere((item) =>
                                                item.product.id == product.id);

                                        return Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                context.read<CartBloc>().add(
                                                    CartItemRemoved(
                                                        product.id));
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Icon(
                                                  Icons.remove,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              child: Text(
                                                '${cartItem.quantity}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                if (product.stock -
                                                        product.threshold <
                                                    cartItem.quantity + 1) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: const Text(
                                                        'Stock limit reached',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      duration: const Duration(
                                                          seconds: 1),
                                                      backgroundColor:
                                                          Colors.red.shade100,
                                                    ),
                                                  );
                                                  return;
                                                }
                                                context.read<CartBloc>().add(
                                                    CartItemAdded(product));
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: product.stock -
                                                              product
                                                                  .threshold <
                                                          cartItem.quantity + 1
                                                      ? Colors.grey
                                                      : Colors.green,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
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
                                        context
                                            .read<CartBloc>()
                                            .add(CartItemAdded(product));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${product.name} added to cart',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                            duration:
                                                const Duration(seconds: 1),
                                            backgroundColor:
                                                Colors.green.shade100,
                                          ),
                                        );
                                      },
                                      style: greenButtonStyle.copyWith(
                                        minimumSize: const WidgetStatePropertyAll(
                                            Size(120,
                                                36) // Smaller button for list view
                                            ),
                                        backgroundColor:
                                            const WidgetStatePropertyAll(
                                                Colors.green),
                                        foregroundColor:
                                            const WidgetStatePropertyAll(
                                                Colors.white),
                                      ),
                                      child: const Text(
                                        "Add to Cart",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    ),
  );
}
