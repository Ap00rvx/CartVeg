import 'package:bloc/bloc.dart';
import 'package:cart_veg/model/invoice_model.dart';
import 'package:cart_veg/service/user_order_serice.dart';
import 'package:equatable/equatable.dart';

part 'invoice_event.dart';
part 'invoice_state.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  InvoiceBloc() : super(InvoiceInitial()) {
    on<GetInvoiceEvent>((event, emit)async {
      emit(InvoiceLoading());
      final result  =await UserOrderService().getInvoice(event.id);
      result.fold(
        (l) => emit(InvoiceError(l)),
        (r) => emit(InvoiceLoaded(r)),
      );
    });
  }
}


