import 'package:cart_veg/config/router/route_names.dart';
import 'package:cart_veg/pages/auth/auth_page.dart';
import 'package:cart_veg/pages/auth/user_details_page.dart';
import 'package:cart_veg/pages/auth/verify_otp_page.dart';
import 'package:cart_veg/pages/checkout/checkout_page.dart';
import 'package:cart_veg/pages/checkout/widget/create_order_loader_page.dart';
import 'package:cart_veg/pages/home/home_page.dart';
import 'package:cart_veg/pages/home/search/search_page.dart';
import 'package:cart_veg/widgets/authentication_validation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: Routes.initial,
  routes: [
    GoRoute(
        path: Routes.initial,
        pageBuilder: (context, state) =>
            const MaterialPage(child: AuthenticationValidation())),
    GoRoute(
        path: Routes.auth,
        pageBuilder: (context, state) => const MaterialPage(child: AuthPage())),
    GoRoute(
      path: Routes.otpVerify, // Define the OTP route
      pageBuilder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? ''; // Extract email
        return MaterialPage(child: OtpVerificationScreen(email: email));
      },
    ),
    GoRoute(
        path: Routes.userDetails,
        pageBuilder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return MaterialPage(
              child: UserDetailsPage(
            email: email, // Pass the email to UserDetailsPage
          ));
        }),
    GoRoute(
        path: Routes.home,
        pageBuilder: (context, state) => const MaterialPage(child: HomePage())),
    GoRoute(
        path: Routes.search,
        pageBuilder: (context, state) =>
            const MaterialPage(child: SearchPage())),
    GoRoute(
      path: Routes.checkout,
      name: "checkout",
      pageBuilder: (context, state) {
        return const MaterialPage(child: CheckoutPage());
      },
    ),
    GoRoute(
      path: "/create-order",
      name: Routes.createOrder,
      pageBuilder: (context, state) {
        return const MaterialPage(child: CreateOrderLoaderPage());
      },
    ),
  ],
);
