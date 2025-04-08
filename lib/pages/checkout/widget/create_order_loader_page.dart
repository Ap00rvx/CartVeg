import 'package:cart_veg/bloc/order/order_bloc.dart';
import 'package:cart_veg/bloc/user_order/user_order_bloc.dart';
import 'package:cart_veg/config/router/route_names.dart';
import 'package:cart_veg/locator.dart';
import 'package:cart_veg/pages/cart/cart_page.dart';
import 'package:cart_veg/service/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

class CreateOrderLoaderPage extends StatefulWidget {
  const CreateOrderLoaderPage({super.key});

  @override
  State<CreateOrderLoaderPage> createState() => _CreateOrderLoaderPageState();
}

class _CreateOrderLoaderPageState extends State<CreateOrderLoaderPage> {
  int _remainingSeconds = 7; // Timer duration in seconds
  bool _timerStarted = false;
  final user = locator<AuthenticationService>().user!;

  @override
  void initState() {
    super.initState();
  }

  void _startTimerAndPop() {
    if (!_timerStarted) {
      _timerStarted = true;
      Future.delayed(Duration(seconds: _remainingSeconds), () {
        if (mounted) {
          context.go(Routes.home); // Only navigates after timer
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Prevents popping via back button at all times
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocListener<OrderBloc, OrderState>(
          listener: (context, state) {
            if (state is OrderCreated || state is OrderError) {
              _startTimerAndPop(); 
              // Start timer only when order is created or errored
               context.read<UserOrderBloc>().add(FetchUserOrders(user.id));
            }
            
          },
          child: BlocBuilder<OrderBloc, OrderState>(
            builder: (context, state) {
              if (state is OrderLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/loading.json', // Add your loading animation
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Processing your order...",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (state is OrderCreated) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Lottie.asset(
                            'assets/order_placed.json',
                            fit: BoxFit.contain,
                            height: 300,
                          ),
                        ),
                      ),
                      const Text(
                        "Order Placed Successfully!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        "Order ID: ${state.response.data.orderId}",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Redirecting in $_remainingSeconds seconds...",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (state is OrderError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.bag_cross1,
                          size: 100, color: Colors.red),
                      const SizedBox(height: 20),
                      const Text(
                        "Oops! Something went wrong",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          state.errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Redirecting in $_remainingSeconds seconds...",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/loading.json', // Add your loading animation
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Processing your order...",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
