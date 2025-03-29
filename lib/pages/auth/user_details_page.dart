import 'package:cart_veg/bloc/auth/authentication_bloc_bloc.dart';
import 'package:cart_veg/config/router/route_names.dart';
import 'package:cart_veg/main.dart';
import 'package:cart_veg/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({super.key, required this.email});
  final String email;

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print(widget.email);
    return Scaffold(
      body: BlocListener<AuthenticationBlocBloc, AuthenticationBlocState>(
        listener: (context, state) {
          if (state is SaveUserDetailsSuccess) {
            showCustomSnackBar(
                context, "Success!", "User details saved", Colors.green);
            Future.delayed(const Duration(seconds: 2), () {
              context.go(Routes.home);
            });
          }
          if (state is AuthenticationBlocFailure) {
            showCustomSnackBar(context, state.errorMessage,
                "Error saving user details", Colors.red);
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
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Text(
                "User Details",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Please fill in your details",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: widget.email,
                decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.green),
                    )),
                enabled: false,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Name',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.green),
                    )),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  } else if (value.length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                    labelText: 'Phone',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.green),
                    )),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number is required';
                  } else if (value.length != 10) {
                    return 'Enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
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
                  if (_formKey.currentState!.validate()) {
                    context
                        .read<AuthenticationBlocBloc>()
                        .add(SaveUserDetailsEvent(
                          _nameController.text,
                          widget.email,
                          _phoneController.text,
                        ));
                  } else {
                    showCustomSnackBar(
                        context, "Please fill all the fields", "", Colors.red);
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
                      "Submit",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
