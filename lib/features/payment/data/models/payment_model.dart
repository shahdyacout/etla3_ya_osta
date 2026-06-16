import '../../domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.bookingId,
    required super.amount,
    required super.paymentMethod,
    super.travelerName,
    super.travelerEmail,
    super.travelerPhone,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'travelerName': travelerName,
      'travelerEmail': travelerEmail,
      'travelerPhone': travelerPhone,
    };
  }
}