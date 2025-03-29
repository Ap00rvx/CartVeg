import 'package:cart_veg/config/router/route_names.dart';
import 'package:cart_veg/pages/auth/auth_page.dart';
import 'package:cart_veg/pages/auth/verify_otp_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: Routes.auth,
  routes: [
    GoRoute(path: Routes.auth,pageBuilder: (context, state) => const MaterialPage(child: AuthPage())),
    GoRoute(
      path: Routes.otpVerify, // Define the OTP route
      pageBuilder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? ''; // Extract email
        return MaterialPage(child: OtpVerificationScreen(email: email));
      },
    ), 

  ],
);
