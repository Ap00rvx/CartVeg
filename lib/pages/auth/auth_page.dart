import 'package:cart_veg/bloc/auth/authentication_bloc_bloc.dart';
import 'package:cart_veg/config/router/app_router.dart';
import 'package:cart_veg/config/router/route_names.dart';
import 'package:cart_veg/pages/auth/verify_otp_page.dart';
import 'package:cart_veg/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthenticationBlocBloc, AuthenticationBlocState>(
        listener: (context, state) {
          if (state is AuthenticationBlocSuccess) {
            showCustomSnackBar(
              context,
              "Success!",
              "${state.successMessage}",
              Colors.green,
            );

            final email = _emailController.text;
            Future.delayed(Duration(seconds: 2), () {
              context.go(
                  '${Routes.otpVerify}?email=${Uri.encodeComponent(email)}');
            });
          }
          if (state is AuthenticationBlocFailure) {
            showCustomSnackBar(context, state.errorMessage,
                "error sending email ", Colors.red);
          }
        },
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/veges.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      persistentFooterButtons: const [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("By confirming, you agree to our Terms and Privacy Policy",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
      bottomSheet: Container(
        height: 300,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Freshness at Your Doorstep, Faster than Ever! 🥦",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              EmailField(controller: _emailController),
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
                  if (_formKey.currentState!.validate()) {
                    context
                        .read<AuthenticationBlocBloc>()
                        .add(SendOtpToEmailEvent(_emailController.text));
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
                      "Continue",
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

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  const EmailField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBlocBloc, AuthenticationBlocState>(
      builder: (context, state) {
        bool isDisabled = state is AuthenticationBlocLoading;

        return TextFormField(
          controller: controller,
          enabled: !isDisabled, // Disable when loading
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            } else if (!RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+")
                .hasMatch(value)) {
              return 'Enter a valid email';
            }
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            prefixIcon: const Icon(Icons.email),
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.green),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
            hintText: "Email",
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        );
      },
    );
  }
}
