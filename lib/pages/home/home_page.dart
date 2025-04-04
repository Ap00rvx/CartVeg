import 'package:cart_veg/bloc/cart/cart_bloc.dart';
import 'package:cart_veg/bloc/search/search_bloc.dart';
import 'package:cart_veg/locator.dart';
import 'package:cart_veg/pages/cart/cart_page.dart';
import 'package:cart_veg/pages/category/category_page.dart';
import 'package:cart_veg/pages/home/widgets/home_content.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cart_veg/pages/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart'; // Import the Iconsax package

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of pages to be shown in the IndexedStack
  final List<Widget> _pages = [
    const HomeContent(),
    const CategoryContent(),
    const CartPage(),
    const ProfilePage()
  ];

 late SearchBloc _searchBloc;
  @override
  void initState() {
    super.initState();
     // Fetch products when the app starts
     _searchBloc = context.read<SearchBloc>(); 
    _searchBloc.add(FetchSearchProducts());
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.green.shade900,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Iconsax.home),
              activeIcon: Icon(Iconsax.home_15),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Iconsax.category),
              activeIcon: Icon(Iconsax.category5),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  int itemCount = 0;
                  if (state is CartLoaded) {
                    itemCount = state.cart.totalItems;
                  }

                  return itemCount > 0
                      ? badges.Badge(
                          badgeContent: itemCount > 0
                              ? Text(
                                  '$itemCount',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                )
                              : null, // Hide badge if count is 0
                          badgeStyle: const badges.BadgeStyle(
                            badgeColor: Colors.grey,
                            padding: EdgeInsets.all(6),
                          ),
                          child: const Icon(Iconsax.shopping_cart),
                        )
                      : const Icon(Iconsax.shopping_cart);
                },
              ),
              activeIcon: BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  int itemCount = 0;
                  if (state is CartLoaded) {
                    itemCount = state.cart.totalItems;
                  }

                  return itemCount > 0
                      ? badges.Badge(
                          badgeContent: itemCount > 0
                              ? Text(
                                  '$itemCount',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                )
                              : null, // Hide badge if count is 0
                          badgeStyle: badges.BadgeStyle(
                            badgeColor: Colors.green.shade900,
                            padding: EdgeInsets.all(6),
                          ),
                          child: const Icon(Iconsax.shopping_cart),
                        )
                      : const Icon(Iconsax.shopping_cart);
                },
              ),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Iconsax.profile_circle),
              activeIcon: Icon(Iconsax.profile_circle5),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}