import 'package:bloc/bloc.dart';
import 'package:cart_veg/model/cart_model.dart';
import 'package:cart_veg/model/product_model.dart';
import 'package:cart_veg/service/cart_service.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartStarted extends CartEvent {}

class CartItemAdded extends CartEvent {
  final Product product;
  const CartItemAdded(this.product);

  @override
  List<Object?> get props => [product];
}

class CartItemRemoved extends CartEvent {
  final String productId;
  const CartItemRemoved(this.productId);

  @override
  List<Object?> get props => [productId];
}

class CartItemDeleted extends CartEvent {
  final String productId;
  const CartItemDeleted(this.productId);

  @override
  List<Object?> get props => [productId];
}

class CartItemQuantityUpdated extends CartEvent {
  final String productId;
  final int quantity;
  const CartItemQuantityUpdated(this.productId, this.quantity);

  @override
  List<Object?> get props => [productId, quantity];
}

class CartCleared extends CartEvent {}

// States
abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final Cart cart;
  const CartLoaded(this.cart);

  @override
  List<Object?> get props => [cart];
}

class CartError extends CartState {
  final String message;
  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class CartBloc extends Bloc<CartEvent, CartState> {
  final CartService _cartService;

  CartBloc({required CartService cartService})
      : _cartService = cartService,
        super(CartInitial()) {
    on<CartStarted>(_onCartStarted);
    on<CartItemAdded>(_onCartItemAdded);
    on<CartItemRemoved>(_onCartItemRemoved);
    on<CartItemQuantityUpdated>(_onCartItemQuantityUpdated);
    on<CartCleared>(_onCartCleared);
    on<CartItemDeleted>(_ondeleteCartItem);
  }

  /// Fetch the cart and update the state
  Future<void> _fetchCart(Emitter<CartState> emit) async {
    final result = await _cartService.getCart();
    result.fold(
      (error) => emit(CartError(error)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  /// Initialize cart
  Future<void> _onCartStarted(
      CartStarted event, Emitter<CartState> emit) async {
    emit(CartLoading());
    await _fetchCart(emit);
  }

  Future<void> _ondeleteCartItem(
      CartItemDeleted event, Emitter<CartState> emit) async {
    if (state is CartLoaded) {
      try {
        final success = await _cartService.deleteItemFromCart(event.productId);
        if (success)
          await _fetchCart(emit);
        else
          emit(const CartError('Failed to remove item from cart'));
      } catch (e) {
        emit(CartError('Failed to remove item: ${e.toString()}'));
      }
    }
  }

  /// Add item to cart
  Future<void> _onCartItemAdded(
      CartItemAdded event, Emitter<CartState> emit) async {
    if (state is CartLoaded) {
      try {
        final success = await _cartService.addToCart(event.product);
        if (success)
          await _fetchCart(emit);
        else
          emit(const CartError('Failed to add item to cart'));
      } catch (e) {
        emit(CartError('Failed to add item: ${e.toString()}'));
      }
    }
  }

  /// Remove item from cart
  Future<void> _onCartItemRemoved(
      CartItemRemoved event, Emitter<CartState> emit) async {
    if (state is CartLoaded) {
      try {
        final success = await _cartService.removeFromCart(event.productId);
        if (success)
          await _fetchCart(emit);
        else
          emit(const CartError('Failed to remove item from cart'));
      } catch (e) {
        emit(CartError('Failed to remove item: ${e.toString()}'));
      }
    }
  }

  /// Update item quantity
  Future<void> _onCartItemQuantityUpdated(
      CartItemQuantityUpdated event, Emitter<CartState> emit) async {
    if (state is CartLoaded) {
      try {
        final success = await _cartService.updateCartItemQuantity(
            event.productId, event.quantity);
        if (success)
          await _fetchCart(emit);
        else
          emit(const CartError('Failed to update item quantity'));
      } catch (e) {
        emit(CartError('Failed to update quantity: ${e.toString()}'));
      }
    }
  }

  /// Clear the cart
  Future<void> _onCartCleared(
      CartCleared event, Emitter<CartState> emit) async {
    if (state is CartLoaded) {
      try {
        final success = await _cartService.clearCart();
        if (success)
          await _fetchCart(emit);
        else
          emit(const CartError('Failed to clear cart'));
      } catch (e) {
        emit(CartError('Failed to clear cart: ${e.toString()}'));
      }
    }
  }
}
