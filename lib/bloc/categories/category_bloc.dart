// category_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../service/home_page_service.dart';


// Events
abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

class LoadCategories extends CategoryEvent {}

// States
abstract class CategoryState extends Equatable {
  const CategoryState();
  
  @override
  List<Object> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoriesLoaded extends CategoryState {
  final List<String> categories;
  final String selectedCategory;

  const CategoriesLoaded({
    required this.categories,
    this.selectedCategory = "",
  });

  CategoriesLoaded copyWith({
    List<String>? categories,
    String? selectedCategory,
  }) {
    return CategoriesLoaded(
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object> get props => [categories, selectedCategory];
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final HomePageService homePageService;

  CategoryBloc({required this.homePageService}) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    
    try {
      final categories = await homePageService.getCategories();
      emit(CategoriesLoaded(categories: categories));
    } catch (e) {
      emit(CategoryError('Failed to load categories: ${e.toString()}'));
    }
  }
}