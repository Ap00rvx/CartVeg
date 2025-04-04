import 'package:cart_veg/config/router/app_router.dart';
import 'package:cart_veg/config/router/route_names.dart';
import 'package:cart_veg/locator.dart';

import 'package:cart_veg/service/authentication_service.dart';
import 'package:cart_veg/service/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = locator.get<AuthenticationService>().user!;
  final String CART_KEY = "user_cart_ffa";

  void showlogoutbottomsheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Are you sure you want to logout?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel")),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      // Clear the cart from local storage
                      await const FlutterSecureStorage().delete(key: CART_KEY);
                      await LocalStorageService()
                          .deleteToken()
                          .then((_) => {context.go(Routes.auth)});
                    },
                    child: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red.shade400,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          locator.get<AuthenticationService>().getUserDetails();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person,
                          size: 50, color: Colors.green.shade500),
                    ),
                    const SizedBox(height: 10),
                    Text(user.name,
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text(user.email,
                        style: const TextStyle(
                            fontSize: 18, color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoTile(Icons.phone, "Phone", user.phone),
                    _buildInfoTile(Icons.verified_user, "Status",
                        user.isActivate ? 'Active' : 'Inactive',
                        textColor: user.isActivate ? Colors.green : Colors.red),
                    const SizedBox(height: 20),
                    const Text("Orders",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    ...user.orders
                        .map((order) => _buildListItem("Order ID: $order"))
                        .toList(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red.shade400,
                            minimumSize: const Size.fromHeight(50),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            )),
                        onPressed: () {
                          showlogoutbottomsheet();
                        },
                        child: const Text("Logout")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value,
      {Color textColor = Colors.black}) {
    return Card(
      color: Colors.grey.shade100,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.green.shade700),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(color: textColor)),
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Card(
        color: Colors.grey.shade100,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(text,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ));
  }
}
