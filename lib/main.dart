import 'package:cart_veg/bloc/auth/authentication_bloc_bloc.dart';
import 'package:cart_veg/bloc/cart/cart_bloc.dart';
import 'package:cart_veg/bloc/categories/category_bloc.dart';
import 'package:cart_veg/bloc/order/order_bloc.dart';
import 'package:cart_veg/bloc/product/product_bloc.dart';
import 'package:cart_veg/bloc/productIds/product_ids_bloc.dart';
import 'package:cart_veg/bloc/search/search_bloc.dart';
import 'package:cart_veg/config/router/app_router.dart';
import 'package:cart_veg/firebase_options.dart';
import 'package:cart_veg/locator.dart';
import 'package:cart_veg/service/cart_service.dart';
import 'package:cart_veg/service/search_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setup();
  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthenticationBlocBloc()),
        BlocProvider<ProductBloc>(
          create: (context) => locator<ProductBloc>(),
        ),
        BlocProvider<CategoryBloc>(
          create: (context) => locator<CategoryBloc>(),
        ),
        BlocProvider(
            create: (context) => CartBloc(cartService: locator<CartService>())),
        BlocProvider(create: (context) => SearchBloc(
          searchService: locator<SearchService>(),
        )),
        BlocProvider(
          create:(context)  => OrderBloc()),
        BlocProvider(
          create:(context)  => ProductIdsBloc()),

      ],
      child: MaterialApp.router(
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: "poppins",
        ),
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
      ),
    );
  }
}
