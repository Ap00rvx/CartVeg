import 'package:cart_veg/bloc/cart/cart_bloc.dart';
import 'package:cart_veg/bloc/productIds/product_ids_bloc.dart';
import 'package:cart_veg/config/router/app_router.dart';
import 'package:cart_veg/config/router/route_names.dart';
import 'package:cart_veg/locator.dart';
import 'package:cart_veg/model/cart_model.dart';
import 'package:cart_veg/model/product_model.dart';
import 'package:cart_veg/pages/checkout/widget/create_order_loader_page.dart';
import 'package:cart_veg/service/cart_service.dart';
import 'package:cart_veg/service/home_page_service.dart';
import 'package:cart_veg/widgets/button_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  var currentProducts = locator<HomePageService>()
      .products
      .map(
        (product) => product.id,
      )
      .toList();

  @override
  @override
  void initState() {
    super.initState();
    // Initialize the CartBloc and load the cart items
    context.read<ProductIdsBloc>().add(ProductIdsFetchEvent());

    context.read<CartBloc>().add(CartStarted());
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && state.cart.items.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    _showClearCartDialog(context);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<CartBloc>().add(CartStarted());
          context.read<ProductIdsBloc>().add(ProductIdsFetchEvent());
        },
        child: BlocBuilder<ProductIdsBloc, ProductIdsState>(
          builder: (context, state) {
            if (state is ProductIdsLoading) {
              return _buildCartShimmer();
            }
            if (state is ProductIdsLoaded) {
              currentProducts =
                  state.productIds.map((e) => e.toString()).toList();
              print(currentProducts);
              return BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  if (state is CartLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    );
                  } else if (state is CartLoaded) {
                    if (state.cart.items.isEmpty) {
                      return _buildEmptyCart(context);
                    }
                    return _buildCartItems(context, state.cart);
                  } else if (state is CartError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 60, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<CartBloc>().add(CartStarted());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Center(child: Text('Something went wrong'));
                },
              );
            }
            if (state is ProductIdsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CartBloc>().add(CartStarted());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }
            return _buildCartShimmer();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Add items to your cart to continue shopping',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildCartShimmer() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              tileColor:
                  Colors.grey.shade100, // Background color similar to Card
              // Padding inside the tile
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    8), // Optional: rounded corners like Card
              ),
              leading: Container(
                width: 100,
                height: double.infinity,
                color: Colors.grey.shade300,
              ),
              title: Container(
                height: 20,
                width: 100,
                color: Colors.grey.shade300,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Container(
                    height: 20,
                    width: 50,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 20,
                    width: 50,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 20,
                    width: 50,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
            ));
      },
      itemCount: 4,
    );
  }

  Widget _buildCartItems(BuildContext context, Cart cart) {
    // Separate available and unavailable items
    final availableItems = cart.items
        .where((item) => currentProducts.contains(item.product.id))
        .toList();
    final unavailableItems = cart.items
        .where((item) => !currentProducts.contains(item.product.id))
        .toList();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Available Items
              if (availableItems.isNotEmpty)
                ...availableItems
                    .map((item) => _buildCartItemTile(context, item, true))
                    .toList(),
              // Unavailable Items
              if (unavailableItems.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Unavailable Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                ...unavailableItems
                    .map((item) => _buildCartItemTile(context, item, false))
                    .toList(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      for (var item in unavailableItems) {
                        context
                            .read<CartBloc>()
                            .add(CartItemRemoved(item.product.id));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Remove All Unavailable Items'),
                  ),
                ),
              ],
            ],
          ),
        ),
        // Cart Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Items:',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '${cart.totalItems}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹${cart.totalAmount}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  
                  onPressed: availableItems.isEmpty
                      ? null // Disable button if no available items
                      : () {
                          context.pushNamed(
                            "checkout",
                            queryParameters: {
                              'totalAmount': cart.totalAmount.toString(),
                              'totalItems': cart.totalItems.toString(),
                            },
                          );
                        },
                  style: greenButtonStyle.copyWith(
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  child: const Text(
                    'PROCEED TO CHECKOUT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartItemTile(
      BuildContext context, CartItem item, bool isAvailable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        tileColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabled: isAvailable,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            item.image,
            width: 100,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${item.product.unit}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            if (isAvailable &&
                item.product.stock - item.product.threshold <= 5 &&
                item.product.stock - item.product.threshold > 0)
              Text(
                'Only ${item.product.stock - item.product.threshold} left',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            if (!isAvailable)
              const Text(
                'Product not available',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            Row(
              children: [
                Text(
                  '₹${item.price}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                if (item.actualPrice > item.price)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      '₹${item.actualPrice}',
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (isAvailable) ...[
                  InkWell(
                    onTap: () {
                      context
                          .read<CartBloc>()
                          .add(CartItemRemoved(item.product.id));
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
                        size: 16,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (item.product.stock - item.product.threshold <
                          item.quantity + 1) {
                        return;
                      }
                      final product = Product.fromJson(item.product.toJson());
                      context.read<CartBloc>().add(CartItemAdded(product));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: item.product.stock - item.product.threshold <
                                item.quantity + 1
                            ? Colors.grey
                            : Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
                if (!isAvailable)
                  InkWell(
                    onTap: () {
                      context
                          .read<CartBloc>()
                          .add(CartItemDeleted(item.product.id));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Remove',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Text(
          'Total: ₹${item.totalPrice}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
            'Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CartBloc>().add(CartCleared());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
  }
}
