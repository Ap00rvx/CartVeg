import 'package:bloc/bloc.dart';
import 'package:cart_veg/locator.dart';
import 'package:cart_veg/model/store_response_model.dart';
import 'package:cart_veg/service/store_service.dart';
import 'package:equatable/equatable.dart';

part 'store_event.dart';
part 'store_state.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  StoreBloc() : super(StoreInitial()) {
    on<FetchStoreEvent>((event, emit) async {
      emit(StoreLoading());
      // Simulate a network caltry 
      try {
        final response = await locator.get<StoreService>().getNearestStore(); 
        response.fold(
          (error) => emit(StoreError(message: error)),
          (nearestStoreResponse) => emit(StoreLoaded(nearestStoreResponse: nearestStoreResponse)),
        );
      }catch(err){
        emit(StoreError(message: err.toString()));
      }
    });
  }
}
