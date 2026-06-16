import '../entities/payment_entity.dart';
import '../entities/payment_result_entity.dart';
import '../repositories/payment_repository.dart';

class CreatePaymentIntentUseCase {
  final PaymentRepository repository;

  CreatePaymentIntentUseCase(this.repository);

  Future<PaymentResultEntity> call(PaymentEntity payment) {
    return repository.createPaymentIntent(payment);
  }
}