part of 'invoice_bloc.dart';

sealed class InvoiceEvent extends Equatable {
  const InvoiceEvent();

  @override
  List<Object> get props => [];
}

class GetInvoiceEvent extends InvoiceEvent {
  final String id;

  const GetInvoiceEvent(this.id);

  @override
  List<Object> get props => [id];
}