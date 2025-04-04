
import 'package:cart_veg/bloc/cart/cart_bloc.dart';
import 'package:cart_veg/service/cart_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartBlocProvider extends StatelessWidget {
  final Widget child;
  
  const CartBlocProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartBloc(
        cartService: CartService(),
      )..add(CartStarted()),
      child: child,
    );
  }
}