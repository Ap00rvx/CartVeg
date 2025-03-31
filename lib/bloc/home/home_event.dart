part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

class GetHomePageDataEvent extends HomeEvent {
  GetHomePageDataEvent();
}
