import 'package:cart_veg/config/constant/constant.dart';
import 'package:cart_veg/locator.dart'; // For locator
import 'package:cart_veg/model/cart_model.dart';
import 'package:cart_veg/model/product_model.dart';
import 'package:cart_veg/service/current_product_service.dart';
import 'package:cart_veg/service/home_page_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';

class CartService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: BASE_URL,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));
  Cart? _cart;
  final String CART_KEY = "user_cart_ffa";
  final _storage = const FlutterSecureStorage();

  Future<Either<String, Cart>> getCart() async {
    try {
      final savedCart = await _storage.read(key: CART_KEY);
      if (savedCart != null) {
        final cart = cartResponseFromJson(savedCart);
        _cart = cart;
        _recalculateCartTotal(); // Recalculate totals based on available products
        await _saveCart(_cart!);
        return right(_cart!);
      }

      _cart = Cart(
        msg: "Cart retrieved successfully",
        items: [],
        totalItems: 0,
        totalAmount: 0,
      );
      await _saveCart(_cart!);
      return right(_cart!);
    } catch (e) {
      print("Error in getCart: $e");
      return left("Failed to get cart");
    }
  }

  Future<bool> addToCart(Product product) async {
    try {
      if (_cart == null) {
        final cartResult = await getCart();
        if (cartResult.isLeft()) return false;
        _cart = cartResult.getRight().toNullable();
      }

      final existingItemIndex =
          _cart!.items.indexWhere((item) => item.product.id == product.id);
      if (existingItemIndex >= 0) {
        _cart!.items[existingItemIndex].quantity += 1;
        _cart!.items[existingItemIndex].totalPrice =
            _cart!.items[existingItemIndex].price *
                _cart!.items[existingItemIndex].quantity;
      } else {
        _cart!.items.add(CartItem(
          product: product,
          name: product.name,
          price: double.parse(product.price.toString()).toInt(),
          quantity: 1,
          image: product.image,
          actualPrice: double.parse(product.actualPrice.toString()).toInt(),
          totalPrice: double.parse(product.price.toString()).toInt(),
        ));
      }

      _recalculateCartTotal();
      await _saveCart(_cart!);
      await _syncCartWithServer();
      return true;
    } catch (e) {
      print("Error in addToCart: $e");
      return false;
    }
  }

  Future<bool> removeFromCart(String productId) async {
    try {
      if (_cart == null) {
        final cartResult = await getCart();
        if (cartResult.isLeft()) return false;
        _cart = cartResult.getRight().toNullable();
      }

      final existingItemIndex =
          _cart!.items.indexWhere((item) => item.product.id == productId);
      if (existingItemIndex >= 0) {
        if (_cart!.items[existingItemIndex].quantity > 1) {
          _cart!.items[existingItemIndex].quantity -= 1;
          _cart!.items[existingItemIndex].totalPrice =
              _cart!.items[existingItemIndex].price *
                  _cart!.items[existingItemIndex].quantity;
        } else {
          _cart!.items.removeAt(existingItemIndex);
        }

        _recalculateCartTotal();
        await _saveCart(_cart!);
        await _syncCartWithServer();
        return true;
      }
      return false;
    } catch (e) {
      print("Error in removeFromCart: $e");
      return false;
    }
  }

  Future<bool> deleteItemFromCart(String productId) async {
    try {
      if (_cart == null) {
        final cartResult = await getCart();
        if (cartResult.isLeft()) return false;
        _cart = cartResult.getRight().toNullable();
      }

      final existingItemIndex =
          _cart!.items.indexWhere((item) => item.product.id == productId);
      if (existingItemIndex >= 0) {
        _cart!.items.removeAt(existingItemIndex);
        _recalculateCartTotal();
        await _saveCart(_cart!);
        await _syncCartWithServer();
        return true;
      }
      return false;
    } catch (e) {
      print("Error in deleteItemFromCart: $e");
      return false;
    }
  }

  Future<bool> updateCartItemQuantity(String productId, int quantity) async {
    try {
      if (_cart == null) {
        final cartResult = await getCart();
        if (cartResult.isLeft()) return false;
        _cart = cartResult.getRight().toNullable();
      }

      final existingItemIndex =
          _cart!.items.indexWhere((item) => item.product.id == productId);
      if (existingItemIndex >= 0) {
        if (quantity <= 0) {
          _cart!.items.removeAt(existingItemIndex);
        } else {
          _cart!.items[existingItemIndex].quantity = quantity;
          _cart!.items[existingItemIndex].totalPrice =
              _cart!.items[existingItemIndex].price * quantity;
        }

        _recalculateCartTotal();
        await _saveCart(_cart!);
        await _syncCartWithServer();
        return true;
      }
      return false;
    } catch (e) {
      print("Error in updateCartItemQuantity: $e");
      return false;
    }
  }

  Future<bool> clearCart() async {
    try {
      _cart = Cart(
        msg: "Cart cleared",
        items: [],
        totalItems: 0,
        totalAmount: 0,
      );
      await _saveCart(_cart!);
      await _syncCartWithServer();
      return true;
    } catch (e) {
      print("Error in clearCart: $e");
      return false;
    }
  }

  // Helper method to save cart to local storage
  Future<void> _saveCart(Cart cart) async {
    final cartJson = cartResponseToJson(cart);
    await _storage.write(key: CART_KEY, value: cartJson);
  }

  // Helper method to recalculate cart total (only for available products)
  void _recalculateCartTotal() {
    int totalItems = 0;
    int totalAmount = 0;

    // Get list of available product IDs from HomePageService
    final currentProductIds = locator<CurrentProductService>().currentProducts;

    print("Current Product IDs: $currentProductIds");

    // Only include available items in the totals
    for (var item in _cart!.items) {
      if (currentProductIds.contains(item.product.id)) {
        totalItems += item.quantity;
        totalAmount += item.totalPrice;
      }
    }

    _cart!.totalItems = totalItems;
    _cart!.totalAmount = totalAmount;
    _cart!.msg = "Cart updated successfully";
  }

  // Helper method to sync cart with server
  Future<void> _syncCartWithServer() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null && token.isNotEmpty) {
        final response = await _dio.post(
          '/api/cart/sync',
          data: _cart!.toJson(),
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        );

        if (response.statusCode == 200) {
          _cart = Cart.fromJson(response.data);
          await _saveCart(_cart!);
        }
      }
    } catch (e) {
      print("Error syncing cart with server: $e");
    }
  }
}
