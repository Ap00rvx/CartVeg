import 'package:cart_veg/bloc/auth/authentication_bloc_bloc.dart';
import 'package:cart_veg/config/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


void main() {
  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthenticationBlocBloc()),
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
