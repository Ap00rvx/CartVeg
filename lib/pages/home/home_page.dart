import 'package:cart_veg/bloc/auth/authentication_bloc_bloc.dart';
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
import 'package:iconsax/iconsax.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const CategoryContent(),
    const CartPage(),
    const ProfilePage(),
  ];

  late SearchBloc _searchBloc;
  late AuthenticationBlocBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _searchBloc = context.read<SearchBloc>();
    _authBloc = context.read<AuthenticationBlocBloc>();
    _authBloc.add(GetUserDetailsEvent());
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
                          badgeContent: Text(
                            '$itemCount',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
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
                          badgeContent: Text(
                            '$itemCount',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                          badgeStyle: badges.BadgeStyle(
                            badgeColor: Colors.green.shade900,
                            padding: const EdgeInsets.all(6),
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
      floatingActionButton: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          int itemCount = 0;
          double totalAmount = 0.0;
          if (state is CartLoaded) {
            itemCount = state.cart.totalItems;
            totalAmount = state.cart.items.fold(
                0.0, (sum, item) => sum + item.totalPrice); // Calculate total
          }
          return (itemCount > 0 && _selectedIndex != 2 && _selectedIndex != 3)
              ? badges.Badge(
                  showBadge: true,
                  position: badges.BadgePosition.topEnd(top: 0, end: 3),
                  badgeStyle: const badges.BadgeStyle(
                    badgeColor: Colors.green,
                    padding: EdgeInsets.all(6),
                  ),
                  badgeContent: Text(
                    '$itemCount',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width -
                        32, // Full width with padding
                    height: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.green.shade900,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIndex =
                                2; // Navigate to CartPage (index 2)
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Iconsax.shopping_bag4,
                                      color: Colors.white, size: 30),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$itemCount Item${itemCount > 1 ? 's' : ''}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'View Cart',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                '₹${totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
