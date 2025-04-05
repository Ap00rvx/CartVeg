import 'dart:convert';

import 'package:cart_veg/bloc/invoice/invoice_bloc.dart';
import 'package:cart_veg/bloc/user_order/user_order_bloc.dart';
import 'package:cart_veg/config/router/app_router.dart';
import 'package:cart_veg/config/router/route_names.dart';
import 'package:cart_veg/locator.dart';
import 'package:cart_veg/model/user_order_model.dart';
import 'package:cart_veg/pages/checkout/checkout_page.dart';
import 'package:cart_veg/service/authentication_service.dart';
import 'package:cart_veg/service/invoice_generator.dart';
import 'package:cart_veg/service/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = locator.get<AuthenticationService>().user!;
  final String CART_KEY = "user_cart_ffa";
  bool _showAllOrders = false; // Track whether to show all orders

  void showLogoutBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Are you sure you want to logout?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await const FlutterSecureStorage().delete(key: CART_KEY);
                      await LocalStorageService().deleteToken().then(
                            (_) => context.go(Routes.auth),
                          );
                    },
                    child: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red.shade400,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<UserOrderBloc>().add(FetchUserOrders(user.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Also refresh orders when pulling down
          context.read<UserOrderBloc>().add(FetchUserOrders(user.id));
          setState(() {}); // Update UI after refresh
        },
        child: BlocListener<InvoiceBloc, InvoiceState>(
          listener: (context, state) async {
            if (state is InvoiceLoaded) {
              final invoiceGenerator = InvoiceGenerator(
                  jsonData: jsonEncode(state.invoice.toJson()));

              final pdfFile = await invoiceGenerator.generateInvoice();

              // Parse JSON to get invoice ID
              final Map<String, dynamic> invoiceData = state.invoice.toJson();
              final invoiceId = invoiceData['invoiceId'];

              // Close loading dialog
              Navigator.pop(context);

              // Navigate to PDF viewer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PDFViewerScreen(
                    pdfFile: pdfFile,
                    invoiceId: invoiceId,
                  ),
                ),
              );
            }
            if (state is InvoiceError) {
              Navigator.pop(context); // Close the loading dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state is InvoiceLoading) {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.green,
                      ),
                    );
                  });
            }
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person,
                            size: 50, color: Colors.green.shade500),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(
                            fontSize: 18, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoTile(Icons.phone, "Phone", user.phone),
                      _buildInfoTile(
                        Icons.verified_user,
                        "Status",
                        user.isActivate ? 'Active' : 'Inactive',
                        textColor: user.isActivate ? Colors.green : Colors.red,
                      ),
                      const SizedBox(height: 20),
                      // Order section with BlocBuilder
                      BlocBuilder<UserOrderBloc, UserOrderState>(
                        builder: (context, state) {
                          if (state is UserOrderLoading) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Getting your orders...",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                ListView.builder(
                                  itemCount: 3, // show 3 shimmer tiles
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.grey.shade300,
                                        highlightColor: Colors.grey.shade100,
                                        child: ListTile(
                                          leading: const CircleAvatar(
                                            backgroundColor: Colors.white,
                                            radius: 24,
                                          ),
                                          title: Container(
                                            height: 12,
                                            color: Colors.white,
                                            margin: EdgeInsets.only(bottom: 8),
                                          ),
                                          subtitle: Container(
                                            height: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                )
                              ],
                            );
                          } else if (state is UserOrderSuccess) {
                            final orders = state.orders;
                            if (orders.isEmpty) {
                              return const Center(
                                child: Text(
                                  "No orders found",
                                  style: TextStyle(fontSize: 16),
                                ),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Recent Orders",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    if (orders.length > 3)
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _showAllOrders = !_showAllOrders;
                                          });
                                        },
                                        child: Text(
                                          _showAllOrders
                                              ? "Show Less"
                                              : "See All",
                                          style: const TextStyle(
                                              color: Colors.green),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ..._getDisplayedOrders(orders)
                                    .map((order) => _buildOrderItem(order))
                                    .toList(),
                              ],
                            );
                          } else if (state is UserOrderFailure) {
                            return Center(
                              child: Column(
                                children: [
                                  Text(
                                    "Error loading orders: ${state.errorMessage}",
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      context
                                          .read<UserOrderBloc>()
                                          .add(FetchUserOrders(user.id));
                                    },
                                    child: const Text("Retry"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // Initial state or any other state
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.green,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red.shade400,
                          minimumSize: const Size.fromHeight(50),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: showLogoutBottomSheet,
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<UserOrder> _getDisplayedOrders(List<UserOrder> orders) {
    // Show only 3 most recent orders unless _showAllOrders is true
    if (_showAllOrders || orders.length <= 3) {
      return orders;
    }
    return orders.sublist(0, 3);
  }

  Widget _buildInfoTile(IconData icon, String title, String value,
      {Color textColor = Colors.black}) {
    return Card(
      color: Colors.grey.shade100,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.green.shade700),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(color: textColor)),
      ),
    );
  }

  Widget _buildOrderItem(UserOrder order) {
    // Format date to a readable format
    final orderDate =
        "${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}";

    return Card(
      color: Colors.grey.shade50,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        title: Text(
          "Order ID: ${order.orderId}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Date: $orderDate • Status: ${order.status}",
          style: TextStyle(
            color: _getStatusColor(order.status),
            fontSize: 14,
          ),
        ),
        leading: Icon(Iconsax.box_tick4, color: _getStatusColor(order.status)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Amount: ₹${order.totalAmount}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("Items: ${order.totalItems}"),
                Text(
                    "Payment: ${order.isCashOnDelivery ? 'Cash on Delivery' : 'Online Payment'}"),
                Text("Payment Status: ${order.paymentStatus}"),
                const SizedBox(height: 10),
                const Text(
                  "Delivery Address:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${order.deliveryAddress.flatno}, ${order.deliveryAddress.street}",
                ),
                Text(
                  "${order.deliveryAddress.city}, ${order.deliveryAddress.state} - ${order.deliveryAddress.pincode}",
                ),
                const SizedBox(height: 10),
                const Text(
                  "Products:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...order.products
                    .map((product) => Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Row(
                            children: [
                              Text(
                                "${product.quantity}x ${product.productId.name}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              const Spacer(),
                              Text(
                                "₹${product.productId.price * product.quantity}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ))
                    .toList(),

                const SizedBox(height: 10),
                // invoice section
                if (order.invoiceId.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      context.read<InvoiceBloc>().add(GetInvoiceEvent(
                            order.invoiceId,
                          ));
                    },
                    child: const Text(
                      "View Invoice",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
