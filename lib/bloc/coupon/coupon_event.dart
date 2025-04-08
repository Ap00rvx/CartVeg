part of 'coupon_bloc.dart';

sealed class CouponEvent extends Equatable {
  const CouponEvent();

  @override
  List<Object> get props => [];
}

final class CouponStarted extends CouponEvent {}

final class ApplyCoupon extends CouponEvent {
  final String couponCode;
  final String userId;
  final int cartTotal;
  const ApplyCoupon(this.couponCode, this.userId, this.cartTotal);

  @override
  List<Object> get props => [couponCode];
}

final class RemoveCoupon extends CouponEvent {
  final String couponCode;
  final String userId;
  const RemoveCoupon(this.couponCode, this.userId);

  @override
  List<Object> get props => [couponCode];
}