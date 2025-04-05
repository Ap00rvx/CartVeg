part of 'invoice_bloc.dart';

sealed class InvoiceState extends Equatable {
  const InvoiceState();
  
  @override
  List<Object> get props => [];
}

final class InvoiceInitial extends InvoiceState {}

final class InvoiceLoading extends InvoiceState {}
final class InvoiceLoaded extends InvoiceState {
  final Invoice invoice;

  const InvoiceLoaded(this.invoice);

  @override
  List<Object> get props => [invoice];
}
final class InvoiceError extends InvoiceState {
  final String message;

  const InvoiceError(this.message);

  @override
  List<Object> get props => [message];
}