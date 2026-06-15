class PaymentResultEntity {
  final bool success;
  final String? checkoutUrl;
  final String? orderId;
  final String? errorMessage;

  const PaymentResultEntity({
    required this.success,
    this.checkoutUrl,
    this.orderId,
    this.errorMessage,
  });
}