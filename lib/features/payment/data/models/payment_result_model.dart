import '../../domain/entities/payment_result_entity.dart';

class PaymentResultModel extends PaymentResultEntity {
  const PaymentResultModel({
    required super.success,
    super.checkoutUrl,
    super.orderId,
    super.errorMessage,
  });

  factory PaymentResultModel.fromJson(Map<String, dynamic> json) {
    return PaymentResultModel(
      success: json['success'] ?? false,
      checkoutUrl: json['checkoutUrl'],
      orderId: json['orderId']?.toString(),
      errorMessage: json['error'],
    );
  }
}