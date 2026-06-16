import '../entities/payment_entity.dart';
import '../entities/payment_result_entity.dart';

abstract class PaymentRepository {
  Future<PaymentResultEntity> createPaymentIntent(PaymentEntity payment);
}