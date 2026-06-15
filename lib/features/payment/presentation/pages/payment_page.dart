import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import 'payment_webview_page.dart';

class PaymentPage extends StatelessWidget {
  final String bookingId;
  final double amount;
  final String travelerName;
  final String travelerPhone;

  const PaymentPage({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.travelerName,
    required this.travelerPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: BlocListener<PaymentCubit, PaymentState>(
        listener: (context, state) {
          if (state is PaymentSuccess) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentWebViewPage(
                  checkoutUrl: state.result.checkoutUrl!,
                  bookingId: bookingId,
                ),
              ),
            );
          } else if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount:'),
                        Text(
                          '$amount EGP',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Booking ID:'),
                        Text(bookingId),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Choose Payment Method:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              BlocBuilder<PaymentCubit, PaymentState>(
                builder: (context, state) {
                  final isLoading = state is PaymentLoading;
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () {
                            context.read<PaymentCubit>().createPayment(
                              bookingId: bookingId,
                              amount: amount,
                              paymentMethod: 'card',
                              travelerName: travelerName,
                              travelerPhone: travelerPhone,
                            );
                          },
                          icon: const Icon(Icons.credit_card),
                          label: const Text('Pay with Visa / Mastercard'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () {
                            context.read<PaymentCubit>().createPayment(
                              bookingId: bookingId,
                              amount: amount,
                              paymentMethod: 'cash',
                              travelerName: travelerName,
                              travelerPhone: travelerPhone,
                            );
                          },
                          icon: const Icon(Icons.phone_android),
                          label: const Text('Pay with Vodafone / Orange Cash'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),

                      if (isLoading) ...[
                        const SizedBox(height: 24),
                        const Center(child: CircularProgressIndicator()),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
