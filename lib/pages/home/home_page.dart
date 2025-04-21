import 'package:cart_veg/bloc/auth/authentication_bloc_bloc.dart';
import 'package:cart_veg/bloc/cart/cart_bloc.dart';
import 'package:cart_veg/bloc/location/location_bloc.dart';
import 'package:cart_veg/bloc/navigation/navigation_bloc.dart';
import 'package:cart_veg/bloc/product/product_bloc.dart';
import 'package:cart_veg/bloc/search/search_bloc.dart';
import 'package:cart_veg/bloc/store/store_bloc.dart';
import 'package:cart_veg/locator.dart';
import 'package:cart_veg/pages/cart/cart_page.dart';
import 'package:cart_veg/pages/category/category_page.dart';
import 'package:cart_veg/pages/home/widgets/home_content.dart';
import 'package:cart_veg/pages/home/widgets/no_loaction.dart';
import 'package:cart_veg/pages/profile/profile_page.dart';
import 'package:cart_veg/service/authentication_service.dart';
import 'package:cart_veg/service/common_service.dart';
import 'package:cart_veg/service/location_service.dart';
import 'package:cart_veg/widgets/loading_shimer_card.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:badges/badges.dart' as badges;
import 'package:palette_generator/palette_generator.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SearchBloc _searchBloc;
  late AuthenticationBlocBloc _authBloc;
  late LocationBloc _locationBloc;
  late CartBloc _cartBloc;

  final categories = locator.get<CommonService>().getCategories();
  Color _appBarColor = Colors.green.shade100; // Default color
  Color _searchBarColor = Colors.green.shade300; // Default color
  bool _colorsLoaded = false;
  final location = locator.get<LocationService>().longitude;
  final user = locator.get<AuthenticationService>().user;
  // Extract colors from flyer image
  Future<void> _extractColorsFromFlyer() async {
    try {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        const AssetImage("assets/images/flyer.jpg"),
        size: const Size(200, 100),
        maximumColorCount: 20,
      );

      final Color appBarColor = paletteGenerator.dominantColor?.color ??
          paletteGenerator.vibrantColor?.color ??
          Colors.green.shade100;

      final Color searchBarColor = paletteGenerator.lightVibrantColor?.color ??
          paletteGenerator.mutedColor?.color ??
          appBarColor.withOpacity(0.7);

      setState(() {
        _appBarColor = appBarColor;
        _searchBarColor = searchBarColor;
        _colorsLoaded = true;
      });
    } catch (e) {
      print("Error extracting colors: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    print("Init State Home Page");
    _searchBloc = context.read<SearchBloc>();
    _authBloc = context.read<AuthenticationBlocBloc>();
    _locationBloc = context.read<LocationBloc>();
    _authBloc.add(GetUserDetailsEvent());
    _searchBloc.add(FetchSearchProducts());
    _locationBloc.add(const FetchLocation());
    _cartBloc = locator<CartBloc>()..add(CartStarted());
    context.read<CartBloc>().add(CartStarted());
    print(categories);
    _extractColorsFromFlyer();
  }

  final key = GlobalKey<ScaffoldState>();

  Color _contrastingTextColor(Color backgroundColor) {
    double luminance = (0.299 * backgroundColor.red +
            0.587 * backgroundColor.green +
            0.114 * backgroundColor.blue) /
        255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBlocBloc, AuthenticationBlocState>(
      builder: (context, state) {
        print(state);
        if (state is AuthenticationBlocLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }
        if (state is AuthenticationBlocFailure) {
          return Center(
            child: Text(
              state.errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        }
        if (state is UserDetailsSuccess) {
          return Scaffold(
            key: key,
            appBar: AppBar(
              backgroundColor: _appBarColor,
              foregroundColor: _contrastingTextColor(_appBarColor),
              toolbarHeight: 80,
              leading: IconButton(
                  onPressed: () {
                    key.currentState!.openDrawer();
                  },
                  icon: const Icon(FluentIcons.navigation_20_regular)),
              elevation: 2,
              title: Visibility(
                visible:
                    context.read<NavigationBloc>().state is! ProfileScreenState,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        fontSize: 16,
                        color: _colorsLoaded
                            ? _contrastingTextColor(_appBarColor)
                            : Colors.green,
                      ),
                    ),
                    Text(
                      user?.name ?? 'Guest',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _colorsLoaded
                            ? _contrastingTextColor(_appBarColor)
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Visibility(
                  visible: context.read<NavigationBloc>().state
                      is! ProfileScreenState,
                  child: GestureDetector(
                    onTap: () {
                      context
                          .read<NavigationBloc>()
                          .add(const NavigateToProfile());
                    },
                    child: CircleAvatar(
                      backgroundColor: _colorsLoaded
                          ? _searchBarColor
                          : Colors.green.withOpacity(0.4),
                      radius: 20,
                      child: Text(
                        user?.name?.substring(0, 1).toUpperCase() ?? 'G',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _colorsLoaded
                              ? _contrastingTextColor(_searchBarColor)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            drawer: _buildDrawer(context),
            body: BlocBuilder<LocationBloc, LocationState>(
              builder: (context, locationState) {
                if (locationState is LocationLoading) {
                  return SingleChildScrollView(child: buildLoadingShimmer());
                } else if (locationState is LocationError) {
                  return const DeliveryNotAvailablePage();
                } else if (locationState is LocationLoaded) {
                  context.read<StoreBloc>().add(FetchStoreEvent(
                      latitude: locationState.latitude,
                      longitude: locationState.longitude));
                  return BlocBuilder<StoreBloc, StoreState>(
                      builder: (context, storeState) {
                    if (storeState is StoreLoading) {
                      return const Center(
                          child: CircularProgressIndicator(
                        color: Colors.green,
                        strokeWidth: 1,
                      ));
                    } else if (storeState is StoreError) {
                      return const DeliveryNotAvailablePage();
                    } else if (storeState is StoreLoaded) {
                      print(storeState.nearestStoreResponse.data.toJson());
                      return BlocBuilder<NavigationBloc, NavigationState>(
                        builder: (context, navState) {
                          if (navState is HomeScreenState) {
                            return const HomeContent();
                          } else if (navState is CategoriesScreenState) {
                            return const CategoryContent();
                          } else if (navState is CartScreenState) {
                            return const CartPage();
                          } else if (navState is ProfileScreenState) {
                            return const ProfilePage();
                          }
                          return const HomeContent(); // Default to Home
                        },
                      );
                    }
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Colors.green,
                      strokeWidth: 1,
                    ));
                  });
                } else {
                  return SingleChildScrollView(child: buildLoadingShimmer());
                }
              },
            ),
            floatingActionButton: BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                int itemCount = 0;
                double totalAmount = 0.0;
                bool isCartOrProfileScreen = context
                        .read<NavigationBloc>()
                        .state is CartScreenState ||
                    context.read<NavigationBloc>().state is ProfileScreenState;

                if (state is CartLoaded) {
                  itemCount = state.cart.totalItems;
                  totalAmount = state.cart.items
                      .fold(0.0, (sum, item) => sum + item.totalPrice);
                }
                print(state);
                return (itemCount > 0 && !isCartOrProfileScreen)
                    ? badges.Badge(
                        showBadge: true,
                        position: badges.BadgePosition.topEnd(top: 0, end: 3),
                        badgeStyle: const badges.BadgeStyle(
                          badgeColor: Colors.green,
                          padding: EdgeInsets.all(6),
                        ),
                        badgeContent: Text(
                          '$itemCount',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width - 32,
                          height: 70,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.green.shade900,
                            child: InkWell(
                              onTap: () {
                                context
                                    .read<NavigationBloc>()
                                    .add(const NavigateToCart());
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        }
        // shimmer scafold use the shimmer package
        return Scaffold(
            appBar: AppBar(
              backgroundColor: _appBarColor,
            ),
            body: SingleChildScrollView(
              child: Center(child: _buildLoadingShimmer()),
            ));
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Container(
            padding: EdgeInsets.only(top: 70, bottom: 30),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade600, Colors.green.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Iconsax.profile_circle,
                    size: 50,
                    color: Colors.green.shade900,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locator.get<AuthenticationService>().user?.name ?? "User",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      locator.get<AuthenticationService>().user?.phone ??
                          "User",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Drawer Items
          Expanded(
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                Container(
                  height: 80,
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade300, Colors.green.shade800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(15)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.money_24,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        "Subscribe now",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20),
                      )
                    ],
                  ),
                ),
                _buildDrawerItem(
                  context,
                  icon: Iconsax.home,
                  activeIcon: Iconsax.home_15,
                  title: 'Home',
                  isSelected:
                      context.watch<NavigationBloc>().state is HomeScreenState,
                  onTap: () {
                    context.read<NavigationBloc>().add(const NavigateToHome());

                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Iconsax.category,
                  activeIcon: Iconsax.category5,
                  title: 'Categories',
                  isSelected: context.watch<NavigationBloc>().state
                      is CategoriesScreenState,
                  onTap: () {
                    context
                        .read<NavigationBloc>()
                        .add(const NavigateToCategories());
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Iconsax.shopping_cart,
                  activeIcon: Iconsax.shopping_cart,
                  title: 'Cart',
                  isSelected:
                      context.watch<NavigationBloc>().state is CartScreenState,
                  badgeContent: BlocBuilder<CartBloc, CartState>(
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
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              badgeStyle: badges.BadgeStyle(
                                badgeColor: Colors.green.shade900,
                                padding: const EdgeInsets.all(6),
                              ),
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                  onTap: () {
                    context.read<NavigationBloc>().add(const NavigateToCart());
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Iconsax.profile_circle,
                  activeIcon: Iconsax.profile_circle5,
                  title: 'Profile',
                  isSelected: context.watch<NavigationBloc>().state
                      is ProfileScreenState,
                  onTap: () {
                    context
                        .read<NavigationBloc>()
                        .add(const NavigateToProfile());
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Iconsax.logout4,
                  activeIcon: Iconsax.login5,
                  title: 'Logout',
                  isSelected: false,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < 3; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.white,
              child: Container(
                width: 150,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.white,
                    child: Container(
                      width: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 14,
                                  width: 100,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 14,
                                  width: 60,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 36,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (i < 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.white,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    Widget? badgeContent,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: isSelected ? Colors.green.shade100 : Colors.transparent,
      child: ListTile(
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? Colors.green.shade900 : Colors.grey,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.green.shade900 : Colors.grey.shade800,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: badgeContent,
        onTap: onTap,
      ),
    );
  }
}
