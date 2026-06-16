class PaymentEntity {
  final String bookingId;
  final double amount;
  final String paymentMethod; // "card" or "cash"
  final String? travelerName;
  final String? travelerEmail;
  final String? travelerPhone;

  const PaymentEntity({
    required this.bookingId,
    required this.amount,
    required this.paymentMethod,
    this.travelerName,
    this.travelerEmail,
    this.travelerPhone,
  });
}