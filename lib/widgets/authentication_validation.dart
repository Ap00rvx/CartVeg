import 'package:cart_veg/bloc/auth/authentication_bloc_bloc.dart';
import 'package:cart_veg/config/router/route_names.dart';
import 'package:cart_veg/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AuthenticationValidation extends StatefulWidget {
  const AuthenticationValidation({super.key});

  @override
  State<AuthenticationValidation> createState() =>
      _AuthenticationValidationState();
}

class _AuthenticationValidationState extends State<AuthenticationValidation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    context.read<AuthenticationBlocBloc>().add(VerifyTokenEvent());

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthenticationBlocBloc, AuthenticationBlocState>(
        listener: (context, state) {
          if (state is VerifyTokenSuccess) {
            if (state.response == true) {
              Future.delayed(const Duration(seconds: 2), () {
                context.go(Routes.home);
              });
            } else {
              context.go(Routes.auth);
            }
          } else if (state is AuthenticationBlocFailure) {
            showCustomSnackBar(context, state.errorMessage,
                "Error Verifying User", Colors.red);
            context.go(Routes.auth);
          }
        },
        child: Center(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Opacity(
                opacity: _animation.value,
                child: const Text(
                  "CART VEG",
                  style: TextStyle(
                    fontSize: 40,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
