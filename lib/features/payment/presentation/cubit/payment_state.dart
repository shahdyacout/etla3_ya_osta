import '../../domain/entities/payment_result_entity.dart';

abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentSuccess extends PaymentState {
  final PaymentResultEntity result;
  PaymentSuccess(this.result);
}

class PaymentError extends PaymentState {
  final String message;
  PaymentError(this.message);
}