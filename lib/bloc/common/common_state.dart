part of 'common_bloc.dart';

sealed class CommonState extends Equatable {
  const CommonState();
  
  @override
  List<Object> get props => [];
}

final class CommonInitial extends CommonState {}

final class CommonLoading extends CommonState{}
final class CommonLoaded extends CommonState{
  final CategoriesResponse categoriesResponse;
  const CommonLoaded({required this.categoriesResponse});
}
final class CommonFailed extends CommonState{
  final String message;
  const CommonFailed({required this.message});
  
  @override
  List<Object> get props => [message];
}