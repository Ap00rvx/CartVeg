import 'dart:math';

import 'package:cart_veg/bloc/cart/cart_bloc.dart';
import 'package:cart_veg/bloc/coupon/coupon_bloc.dart';
import 'package:cart_veg/bloc/order/order_bloc.dart';
import 'package:cart_veg/config/router/route_names.dart';
import 'package:cart_veg/locator.dart';
import 'package:cart_veg/model/cart_model.dart';
import 'package:cart_veg/model/coupon_model.dart';
import 'package:cart_veg/service/authentication_service.dart';
import 'package:cart_veg/service/current_product_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool isCashOnDelivery = true;
  final TextEditingController _couponController = TextEditingController();
  final user = locator.get<AuthenticationService>().user!;
  late CouponBloc _couponBloc;
  String? appliedCouponCode;

  // Address controllers
  late TextEditingController _phoneController;
  final TextEditingController _flatnoController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  // FlutterSecureStorage instance
  final _storage = const FlutterSecureStorage();

  // Address data
  bool _isLoadingAddress = true;
  bool _hasAddress = false;
  Map<String, dynamic>? _savedAddress;
  bool _showAddNewAddress = false;

  // Cart-related data
  late double subtotal;
  double shipping = 40.00;
  double discount = 0.0;
  late List<CartItem> availableItems;
  late List<CartItem> unavailableItems;

  @override
  void initState() {
    super.initState();
    _couponBloc = locator.get<CouponBloc>()..add(CouponStarted());
    _initializeCartData();
    _fetchSavedAddress();
    _phoneController = TextEditingController(text: user.phone);
    _loadAppliedCoupon();
  }

  @override
  void dispose() {
    if (appliedCouponCode != null) {
      _storage.write(key: 'applied_coupon', value: appliedCouponCode);
    } else {
      _storage.delete(key: 'applied_coupon');
    }
    _couponController.dispose();
    _phoneController.dispose();
    _flatnoController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _couponBloc.close();
    super.dispose();
  }

  void _initializeCartData() {
    final cartState = context.read<CartBloc>().state as CartLoaded;
    final cart = cartState.cart;

    final currentProductIds =
        locator<CurrentProductService>().currentProducts.toList();
    availableItems = cart.items
        .where((item) => currentProductIds.contains(item.product.id))
        .toList();
    unavailableItems = cart.items
        .where((item) => !currentProductIds.contains(item.product.id))
        .toList();
    subtotal = availableItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  Future<void> _fetchSavedAddress() async {
    try {
      final addressJson = await _storage.read(key: 'delivery_address');
      final phoneNumber = await _storage.read(key: 'phone_number');

      if (addressJson != null) {
        setState(() {
          _savedAddress = json.decode(addressJson);
          _hasAddress = true;
          _isLoadingAddress = false;
          if (phoneNumber != null) _phoneController.text = phoneNumber;
        });
      } else {
        setState(() {
          _isLoadingAddress = false;
          _hasAddress = false;
          _showAddNewAddress = true;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingAddress = false;
        _hasAddress = false;
        _showAddNewAddress = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error loading saved address: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _saveAddress() async {
    if (_flatnoController.text.isEmpty ||
        _streetController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _stateController.text.isEmpty ||
        _pincodeController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all address fields'),
            backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final addressData = {
        "flatno": _flatnoController.text,
        "street": _streetController.text,
        "city": _cityController.text,
        "state": _stateController.text,
        "pincode": _pincodeController.text,
      };

      await _storage.write(
          key: 'delivery_address', value: json.encode(addressData));
      await _storage.write(key: 'phone_number', value: _phoneController.text);

      setState(() {
        _savedAddress = addressData;
        _hasAddress = true;
        _showAddNewAddress = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Address saved successfully'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error saving address: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _loadAppliedCoupon() async {
    final savedCoupon = await _storage.read(key: 'applied_coupon');
    if (savedCoupon != null && context.mounted) {
      _couponController.text = savedCoupon;
      context
          .read<CouponBloc>()
          .add(ApplyCoupon(savedCoupon, user.id, subtotal.toInt()));
    }
  }

  void _applyCouponDiscount(String couponCode, List<Coupon> coupons) {
    final coupon = coupons.firstWhere(
      (c) => c.couponCode.toUpperCase() == couponCode.toUpperCase(),
      orElse: () => Coupon(
        id: '',
        minValue: 0,
        expiry: DateTime.now(),
        maxUsage: 0,
        couponCode: '',
        offValue: 0,
        isActive: false,
        isDeleted: false,
        usedUsers: [],
        v: 0,
      ),
    );

    if (coupon.couponCode.isNotEmpty &&
        coupon.isActive &&
        !coupon.isDeleted &&
        subtotal >= coupon.minValue &&
        coupon.expiry.isAfter(DateTime.now()) &&
        (coupon.maxUsage > coupon.usedUsers.length)) {
      setState(() {
        discount = coupon.offValue.toDouble();
        appliedCouponCode = coupon.couponCode;
      });
    } else {
      setState(() {
        appliedCouponCode = null; // Reset if invalid
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            coupon.couponCode.isEmpty
                ? 'Invalid coupon'
                : !coupon.isActive
                    ? 'Coupon is inactive'
                    : coupon.isDeleted
                        ? 'Coupon is deleted'
                        : subtotal < coupon.minValue
                            ? 'Cart total too low for this coupon'
                            : coupon.expiry.isBefore(DateTime.now())
                                ? 'Coupon has expired'
                                : 'Coupon usage limit reached',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _couponBloc,
      child: Scaffold(
        appBar: AppBar(
            title: const Text('Checkout'), centerTitle: true, elevation: 0),
        body: SafeArea(
          child: BlocConsumer<CouponBloc, CouponState>(
            listener: (context, state) {
              if (state is CouponApplied) {
                if (state.message.contains("applied")) {
                  _applyCouponDiscount(
                      _couponController.text.toUpperCase(), state.coupons);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green),
                  );
                } else if (state.message.contains("removed")) {
                  setState(() {
                    discount = 0;
                    shipping = 40.00;
                    appliedCouponCode = null;
                    _couponController.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green),
                  );
                  // fetch coupons
                  context.read<CouponBloc>().add(CouponStarted());
                }
              } else if (state is CouponError) {
                setState(() {
                  appliedCouponCode = null; // Reset on error
                  discount = 0;
                  shipping = 40.00;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red),
                );
                context.read<CouponBloc>().add(CouponStarted());
              }
            },
            builder: (context, state) {
              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  if (unavailableItems.isNotEmpty) ...[
                    Card(
                      elevation: 0,
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Unavailable Items',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red)),
                            const SizedBox(height: 8),
                            const Text(
                                'The following items in your cart are unavailable and excluded from this order:',
                                style: TextStyle(color: Colors.red)),
                            const SizedBox(height: 8),
                            ...unavailableItems.map((item) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          "${item.name} (${item.product.unit}) x ${item.quantity}",
                                          style: const TextStyle(
                                              color: Colors.red)),
                                      Text('₹${item.totalPrice}',
                                          style: const TextStyle(
                                              color: Colors.red)),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (availableItems.isNotEmpty) ...[
                    Card(
                      elevation: 0,
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Items',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade900)),
                            const SizedBox(height: 8),
                            ...availableItems.map((item) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          "${item.name} (${item.product.unit}) x ${item.quantity}",
                                          style: TextStyle(
                                              color: Colors.green.shade900)),
                                      Text('₹${item.totalPrice}',
                                          style: TextStyle(
                                              color: Colors.green.shade900)),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                  Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Order Summary',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          _buildOrderSummaryRow('Subtotal (Available Items)',
                              '₹${subtotal.toStringAsFixed(2)}'),
                          _buildOrderSummaryRow(
                              'Shipping', '₹${shipping.toStringAsFixed(2)}'),
                          if (discount > 0)
                            _buildOrderSummaryRow(
                                'Discount', '-₹${discount.toStringAsFixed(2)}'),
                          const Divider(),
                          _buildOrderSummaryRow('Total',
                              '₹${(subtotal + shipping - discount).toStringAsFixed(2)}',
                              isTotal: true),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Apply Coupon',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _couponController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter coupon code',
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.1)),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.1)),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    enabled: appliedCouponCode == null,
                                    suffixIcon: appliedCouponCode != null
                                        ? const Icon(Icons.check_circle,
                                            color: Colors.green)
                                        : null,
                                  ),
                                  textCapitalization:
                                      TextCapitalization.characters,
                                ),
                              ),
                              const SizedBox(width: 10),
                              TextButton(
                                onPressed: appliedCouponCode != null ||
                                        state is CouponLoading
                                    ? null
                                    : () {
                                        if (_couponController.text.isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Please enter a coupon code'),
                                                backgroundColor: Colors.red),
                                          );
                                          return;
                                        }
                                        context.read<CouponBloc>().add(
                                            ApplyCoupon(_couponController.text,
                                                user.id, subtotal.toInt()));
                                      },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 20),
                                ),
                                child: state is CouponLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))
                                    : const Text('Apply'),
                              ),
                            ],
                          ),
                          if (appliedCouponCode != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.local_offer,
                                      size: 16, color: Colors.green),
                                  const SizedBox(width: 4),
                                  Text('Coupon "$appliedCouponCode" applied!',
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w500)),
                                  const Spacer(),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.red),
                                    onPressed: () {
                                      context.read<CouponBloc>().add(
                                          RemoveCoupon(
                                              appliedCouponCode!, user.id));
                                    },
                                    child: const Text('Remove'),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: appliedCouponCode != null
                                ? null
                                : () => _showCouponOffers(context),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.blue),
                            child: const Text('View Available Offers'),
                          ),
                          if (state is CouponLoaded &&
                              appliedCouponCode == null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: state.coupons
                                  .where((coupon) =>
                                      coupon.isActive && !coupon.isDeleted)
                                  .map(
                                      (coupon) => _buildCouponOfferTile(coupon))
                                  .toList()
                                  .sublist(0, min(3, state.coupons.length)),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Delivering To',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              if (_hasAddress && !_showAddNewAddress)
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _showAddNewAddress = true;
                                      _flatnoController.text =
                                          _savedAddress!['flatno'] ?? '';
                                      _streetController.text =
                                          _savedAddress!['street'] ?? '';
                                      _cityController.text =
                                          _savedAddress!['city'] ?? '';
                                      _stateController.text =
                                          _savedAddress!['state'] ?? '';
                                      _pincodeController.text =
                                          _savedAddress!['pincode'] ?? '';
                                    });
                                  },
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text('Edit'),
                                ),
                            ],
                          ),
                          Text(user.name,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w600)),
                          if (_phoneController.text.isNotEmpty)
                            Text(_phoneController.text,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal)),
                          if (_phoneController.text.isEmpty)
                            _buildTextField(
                                _phoneController, "Phone", TextInputType.phone),
                          const SizedBox(height: 10),
                          if (_isLoadingAddress)
                            const Center(child: CircularProgressIndicator())
                          else if (_hasAddress && !_showAddNewAddress)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildAddressField('Flat/House',
                                    _savedAddress!['flatno'] ?? ''),
                                _buildAddressField(
                                    'Street', _savedAddress!['street'] ?? ''),
                                Row(
                                  children: [
                                    Expanded(
                                        child: _buildAddressField('City',
                                            _savedAddress!['city'] ?? '')),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: _buildAddressField('State',
                                            _savedAddress!['state'] ?? '')),
                                  ],
                                ),
                                _buildAddressField(
                                    'Pincode', _savedAddress!['pincode'] ?? ''),
                              ],
                            )
                          else if (_showAddNewAddress)
                            Column(
                              children: [
                                const SizedBox(height: 8),
                                _buildTextField(_flatnoController,
                                    'Flat/House Number', TextInputType.text),
                                const SizedBox(height: 8),
                                _buildTextField(_streetController,
                                    'Street/Area', TextInputType.text),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: _buildTextField(_cityController,
                                            'City', TextInputType.text)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: _buildTextField(_stateController,
                                            'State', TextInputType.text)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildTextField(_pincodeController, 'Pincode',
                                    TextInputType.number),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (_hasAddress)
                                      TextButton(
                                        onPressed: () => setState(
                                            () => _showAddNewAddress = false),
                                        style: TextButton.styleFrom(
                                            foregroundColor: Colors.red),
                                        child: const Text('Cancel'),
                                      ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: _saveAddress,
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.green.shade800,
                                          foregroundColor: Colors.white),
                                      child: const Text('Save Address'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Payment Method',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          _buildPaymentOption(
                            title: 'Cash on Delivery',
                            icon: Icons.money,
                            isSelected: isCashOnDelivery,
                            onTap: () =>
                                setState(() => isCashOnDelivery = true),
                          ),
                          const SizedBox(height: 12),
                          _buildPaymentOption(
                            title: 'Online Payment',
                            icon: Icons.credit_card,
                            isSelected: !isCashOnDelivery,
                            onTap: () =>
                                setState(() => isCashOnDelivery = false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: availableItems.isEmpty ||
                              (!_hasAddress && !_showAddNewAddress)
                          ? null
                          : () {
                              if (_showAddNewAddress) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Please save your address first'),
                                      backgroundColor: Colors.red),
                                );
                                return;
                              }
                              if (isCashOnDelivery) {
                                final products = availableItems
                                    .map((item) => {
                                          "productId": item.product.id,
                                          "quantity": item.quantity,
                                        })
                                    .toList();
                                Map<String, dynamic> address =
                                    _savedAddress != null
                                        ? {
                                            "flatno": _savedAddress!['flatno'],
                                            "street": _savedAddress!['street'],
                                            "city": _savedAddress!['city'],
                                            "state": _savedAddress!['state'],
                                            "pincode":
                                                _savedAddress!['pincode'],
                                          }
                                        : {
                                            "flatno": _flatnoController.text,
                                            "street": _streetController.text,
                                            "city": _cityController.text,
                                            "state": _stateController.text,
                                            "pincode": _pincodeController.text,
                                          };

                                // Get couponId from CouponBloc state
                                String? couponId;
                                final couponState =
                                    context.read<CouponBloc>().state;
                                if (couponState is CouponApplied &&
                                    appliedCouponCode != null) {
                                  final matchingCoupon =
                                      couponState.coupons.firstWhere(
                                    (coupon) =>
                                        coupon.couponCode.toUpperCase() ==
                                        appliedCouponCode!.toUpperCase(),
                                    orElse: () => Coupon(
                                      id: '',
                                      minValue: 0,
                                      expiry: DateTime.now(),
                                      maxUsage: 0,
                                      couponCode: '',
                                      offValue: 0,
                                      isActive: false,
                                      isDeleted: false,
                                      usedUsers: [],
                                      v: 0,
                                    ),
                                  );
                                  if (matchingCoupon.id.isNotEmpty) {
                                    couponId = matchingCoupon
                                        .id; // This is the Mongoose ObjectId
                                  }
                                }

                                context.read<OrderBloc>().add(CreateOrderEvent(
                                      phone: _phoneController.text,
                                      deliveryAddress: address,
                                      isCashOnDelivery: true,
                                      products: products,
                                      shippingAmount: shipping.toInt(),
                                      couponId:
                                          couponId, // Pass the fetched couponId
                                      couponCode:
                                          appliedCouponCode, // Already tracked as appliedCouponCode
                                      couponDiscount: discount > 0
                                          ? discount.toInt()
                                          : null, // From CheckoutPage state
                                    ));
                                context.pushNamed(Routes.createOrder);
                              } else {
                                // Handle online payment flow (to be implemented)
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade800,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: Text(
                        isCashOnDelivery ? 'Place Order' : 'Proceed to Payment',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      TextInputType keyboardType) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.green.shade900),
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      keyboardType: keyboardType,
    );
  }

  Widget _buildAddressField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 2),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryRow(String label, String value,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isTotal ? 16 : 14,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(
            value == "₹0.00" ? "Free" : value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              color: value == "₹0.00" ? Colors.green : Colors.grey.shade900,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
      {required String title,
      required IconData icon,
      required bool isSelected,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
              color: isSelected ? Colors.green.shade700 : Colors.grey.shade300,
              width: 2),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? Colors.green.shade700 : Colors.grey,
                size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? Colors.green.shade900 : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Colors.green.shade700, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponOfferTile(Coupon coupon) {
    final userId = locator.get<AuthenticationService>().user!.id;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        enabled: coupon.usedUsers.contains(userId) == false,
        title: Text(coupon.couponCode,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
            Text('Get ₹${coupon.offValue} off (Min. ₹${coupon.minValue})'),
        trailing: ElevatedButton(
          onPressed: () {
            if (coupon.usedUsers.contains(userId)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Coupon already used'),
                    backgroundColor: Colors.red),
              );
              return;
            }
            _couponController.text = coupon.couponCode;
          
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: coupon.usedUsers.contains(userId)
                ? Colors.grey
                : Colors.green.shade800,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Apply'),
        ),
        tileColor: Colors.grey.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showCouponOffers(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BlocBuilder<CouponBloc, CouponState>(
          bloc: _couponBloc,
          builder: (context, state) {
            if (state is CouponLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CouponLoaded) {
              final activeCoupons = state.coupons
                  .where((coupon) => coupon.isActive && !coupon.isDeleted)
                  .toList();
              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const Text('Available Coupon Offers',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (activeCoupons.isEmpty)
                    const Center(child: Text('No coupons available'))
                  else
                    ...activeCoupons
                        .map((coupon) => _buildCouponOfferTile(coupon)),
                ],
              );
            } else if (state is CouponError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('No coupons loaded'));
          },
        );
      },
    );
  }
}
