part of 'coupon_bloc.dart';

abstract class CouponState extends Equatable {
  const CouponState();

  @override
  List<Object?> get props => [];
}

class CouponInitial extends CouponState {}

class CouponLoading extends CouponState {}

class CouponLoaded extends CouponState {
  final List<Coupon> coupons;

  const CouponLoaded(this.coupons);

  @override
  List<Object?> get props => [coupons];
}

class CouponApplied extends CouponState {
  final String message;
  final List<Coupon> coupons;

  const CouponApplied({required this.message, required this.coupons});

  @override
  List<Object?> get props => [message, coupons];
}

class CouponError extends CouponState {
  final String message;

  const CouponError(this.message);

  @override
  List<Object?> get props => [message];
}