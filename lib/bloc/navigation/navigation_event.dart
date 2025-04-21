part of 'navigation_bloc.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object> get props => [];
}

class NavigateToHome extends NavigationEvent {
  const NavigateToHome();
}

class NavigateToCategories extends NavigationEvent {
  const NavigateToCategories();
}

class NavigateToCart extends NavigationEvent {
  const NavigateToCart();
}

class NavigateToProfile extends NavigationEvent {
  const NavigateToProfile();
}