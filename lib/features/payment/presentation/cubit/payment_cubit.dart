import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/use_case/create_payment_intent_usecase.dart';
import 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final CreatePaymentIntentUseCase createPaymentIntentUseCase;

  PaymentCubit(this.createPaymentIntentUseCase) : super(PaymentInitial());

  Future<void> createPayment({
    required String bookingId,
    required double amount,
    required String paymentMethod,
    String? travelerName,
    String? travelerEmail,
    String? travelerPhone,
  }) async {
    emit(PaymentLoading());

    final result = await createPaymentIntentUseCase(
      PaymentEntity(
        bookingId: bookingId,
        amount: amount,
        paymentMethod: paymentMethod,
        travelerName: travelerName,
        travelerEmail: travelerEmail,
        travelerPhone: travelerPhone,
      ),
    );

    if (result.success && result.checkoutUrl != null) {
      emit(PaymentSuccess(result));
    } else {
      emit(PaymentError(result.errorMessage ?? 'حدث خطأ في الدفع'));
    }
  }
}