import 'package:bloc/bloc.dart';
import 'package:cart_veg/locator.dart';
import 'package:cart_veg/service/current_product_service.dart';
import 'package:equatable/equatable.dart';

part 'product_ids_event.dart';
part 'product_ids_state.dart';

class ProductIdsBloc extends Bloc<ProductIdsEvent, ProductIdsState> {
  ProductIdsBloc() : super(ProductIdsInitial()) {
    on<ProductIdsFetchEvent>(_onFetchCurrentProducts);
  }
  /// Fetch current products
  Future<void> _onFetchCurrentProducts(
      ProductIdsFetchEvent event, Emitter<ProductIdsState> emit) async {
    try {
      final response = await locator.get<CurrentProductService>().getCurrentProducts(); 
      response.fold(
        (error) {
          emit(ProductIdsError(errorMessage: error));
        },
        (data) {
          emit(ProductIdsLoaded(productIds: data));
        },
      );
      
    } catch (e) {
      emit(ProductIdsError(errorMessage: e.toString()));

    }
  }
}
