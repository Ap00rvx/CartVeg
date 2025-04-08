import 'package:bloc/bloc.dart';
import 'package:cart_veg/model/coupon_model.dart';
import 'package:cart_veg/service/coupon_service.dart';
import 'package:equatable/equatable.dart';

part 'coupon_event.dart';
part 'coupon_state.dart';

class CouponBloc extends Bloc<CouponEvent, CouponState> {
  final CouponService _couponService;
  List<Coupon> _currentCoupons = []; // Store coupons internally

  CouponBloc({CouponService? couponService})
      : _couponService = couponService ?? CouponService(),
        super(CouponInitial()) {
    on<CouponStarted>(_onCouponStarted);
    on<ApplyCoupon>(_onApplyCoupon);
    on<RemoveCoupon>(_onRemoveCoupon);
  }

  Future<void> _onCouponStarted(CouponStarted event, Emitter<CouponState> emit) async {
    emit(CouponLoading());
    try {
      final result = await _couponService.getCoupons();
      result.fold(
        (error) => emit(CouponError(error)),
        (coupons) {
          _currentCoupons = coupons; // Update internal list
          emit(CouponLoaded(coupons));
        },
      );
    } catch (e) {
      emit(CouponError('Failed to load coupons: $e'));
    }
  }

  Future<void> _onApplyCoupon(ApplyCoupon event, Emitter<CouponState> emit) async {
    emit(CouponLoading());
    try {
      final result = await _couponService.applyCoupon(
        event.couponCode,
        event.userId,
        event.cartTotal,
      );
      await result.fold(
        (error) async => emit(CouponError(error)),
        (message) async {
          // Refresh the coupon list after applying
          final updatedResult = await _couponService.getCoupons();
          updatedResult.fold(
            (error) => emit(CouponError(error)),
            (coupons) {
              _currentCoupons = coupons;
              emit(CouponApplied(message: message, coupons: _currentCoupons));
            },
          );
        },
      );
    } catch (e) {
      emit(CouponError('Failed to apply coupon: $e'));
    }
  }

  Future<void> _onRemoveCoupon(RemoveCoupon event, Emitter<CouponState> emit) async {
    emit(CouponLoading());
    try {
      final result = await _couponService.removeCoupon(event.couponCode, event.userId);
      await result.fold(
        (error) async => emit(CouponError(error)),
        (message) async {
          // Refresh the coupon list after removing
          final updatedResult = await _couponService.getCoupons();
          updatedResult.fold(
            (error) => emit(CouponError(error)),
            (coupons) {
              _currentCoupons = coupons;
              emit(CouponApplied(message: message, coupons: _currentCoupons));
            },
          );
        },
      );
    } catch (e) {
      emit(CouponError('Failed to remove coupon: $e'));
    }
  }
}