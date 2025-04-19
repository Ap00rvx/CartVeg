import 'package:bloc/bloc.dart';
import 'package:cart_veg/locator.dart';
import 'package:cart_veg/model/categories_model.dart';
import 'package:cart_veg/service/common_service.dart';
import 'package:equatable/equatable.dart';

part 'common_event.dart';
part 'common_state.dart';

class CommonBloc extends Bloc<CommonEvent, CommonState> {
  CommonBloc() : super(CommonInitial()) {
    on<GeCategories>((event, emit) async {
      final service = locator.get<CommonService>();

      emit(CommonLoading());
      try {
        final response = await service.getCategories();
        response.fold(
          (l) => emit(CommonFailed(message: l)),
          (r) => emit(CommonLoaded(categoriesResponse: r)),
        );

        // print("Categories Response: ${response.categories}");
      } catch (e) {
        emit(CommonFailed(message: e.toString()));
      }
    });
  }
}
