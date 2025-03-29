import 'package:cart_veg/bloc/auth/authentication_bloc_bloc.dart';
import 'package:cart_veg/config/router/app_router.dart';
import 'package:cart_veg/config/router/route_names.dart';
import 'package:cart_veg/main.dart';
import 'package:cart_veg/service/local_storage.dart';
import 'package:cart_veg/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, required this.email});
  final String email;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
        leading: IconButton(
            onPressed: () {
              context.go(Routes.auth);
            },
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      backgroundColor: Colors.white,
      body: BlocListener<AuthenticationBlocBloc, AuthenticationBlocState>(
        listener: (context, state) async {
          if (state is VerifyOtpSuccess) {
            showCustomSnackBar(
                context, "Success!", "OTP Verified", Colors.green);
            final user = state.response.data.user;
            final token = state.response.data.token;
            await LocalStorageService().saveToken(token);
            Future.delayed(const Duration(seconds: 2), () {
              if (user.name == "" || user.phone == "") {
                context.go(
                    '${Routes.userDetails}?email=${Uri.encodeComponent(widget.email)}');
              } else {
                context.go(Routes.home);
              }
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/otp.jpg',
                  height: 150), // Replace with your asset
              const SizedBox(height: 20),
              const Text(
                "OTP Verification",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Your OTP has been sent to your\nregistered email ${widget.email}",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Pinput(
                length: 6,
                controller: _otpController,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade700, width: 2),
                  ),
                ),
                showCursor: false,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "Didn't receive OTP? Resend OTP",
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.watch<AuthenticationBlocBloc>().state
                          is AuthenticationBlocLoading
                      ? Colors.grey
                      : Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 60),
                ),
                onPressed: () {
                  if (context.read<AuthenticationBlocBloc>().state
                      is AuthenticationBlocLoading) {
                    return;
                  }
                  if (_otpController.text.isEmpty) {
                    showCustomSnackBar(
                        context, "Error!", "Please enter OTP", Colors.red);
                  }
                  if (_otpController.text.length == 6) {
                    context
                        .read<AuthenticationBlocBloc>()
                        .add(VerifyOtpEvent(_otpController.text, widget.email));
                  } else {
                    showCustomSnackBar(context, "Error!",
                        "Please enter valid OTP", Colors.red);
                  }
                },
                child: BlocBuilder<AuthenticationBlocBloc,
                    AuthenticationBlocState>(
                  builder: (context, state) {
                    if (state is AuthenticationBlocLoading) {
                      return const CircularProgressIndicator(
                          color: Colors.white);
                    }
                    return const Text(
                      "Verify ",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
