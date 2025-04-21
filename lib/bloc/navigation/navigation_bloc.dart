import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const HomeScreenState()) {
    on<NavigateToHome>((event, emit) => emit(const HomeScreenState()));
    on<NavigateToCategories>((event, emit) => emit(const CategoriesScreenState()));
    on<NavigateToCart>((event, emit) => emit(const CartScreenState()));
    on<NavigateToProfile>((event, emit) => emit(const ProfileScreenState()));
  }
}