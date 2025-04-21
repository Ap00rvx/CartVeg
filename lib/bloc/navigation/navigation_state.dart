part of 'navigation_bloc.dart';

abstract class NavigationState extends Equatable {
  const NavigationState();

  @override
  List<Object> get props => [];
}

class HomeScreenState extends NavigationState {
  const HomeScreenState();
}

class CategoriesScreenState extends NavigationState {
  const CategoriesScreenState();
}

class CartScreenState extends NavigationState {
  const CartScreenState();
}

class ProfileScreenState extends NavigationState {
  const ProfileScreenState();
}