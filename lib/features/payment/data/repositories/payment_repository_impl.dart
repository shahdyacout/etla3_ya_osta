import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/payment_result_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../models/payment_model.dart';
import '../models/payment_result_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final String functionUrl =
      'https://masar-payment-server.onrender.com/createPaymentIntent';

  @override
  Future<PaymentResultEntity> createPaymentIntent(PaymentEntity payment) async {
    try {
      final model = PaymentModel(
        bookingId: payment.bookingId,
        amount: payment.amount,
        paymentMethod: payment.paymentMethod,
        travelerName: payment.travelerName,
        travelerEmail: payment.travelerEmail,
        travelerPhone: payment.travelerPhone,
      );

      final response = await http.post(
        Uri.parse(functionUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(model.toJson()),
      );

      final json = jsonDecode(response.body);
      return PaymentResultModel.fromJson(json);
    } catch (e) {
      return PaymentResultModel(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }
}