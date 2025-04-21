import 'package:flutter/material.dart';

class DeliveryNotAvailablePage extends StatelessWidget {
  const DeliveryNotAvailablePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background for a clean look
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image
                Image.asset(
                  'assets/images/nolocation.png',
                  height: 400,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'Delivery Not Available',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Subtitle/Description
                Text(
                  'We’re sorry, delivery is not available in your area at the moment. Please check back later or try a different location.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Action Button
              ],
            ),
          ),
        ),
      ),
    );
  }
}
