import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/entities/trip_entity.dart';
import 'package:etla3_ya_osta/features/traveler/presentation/booking/cubit/booking_cubit.dart';
import 'package:etla3_ya_osta/features/traveler/presentation/booking/cubit/booking_state.dart';
import 'package:etla3_ya_osta/core/theme/app_colors.dart';

class PaymentPage extends StatefulWidget {
  final String bookingId;
  final double amount;
  final String travelerName;
  final String travelerPhone;
  final TripEntity? trip;
  final String? travelerId;
  final int? seatNumber;
  final String? driverId;

  const PaymentPage({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.travelerName,
    required this.travelerPhone,
    this.trip,
    this.travelerId,
    this.seatNumber,
    this.driverId,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isProcessing = false;

  void _processPayment() async {
    setState(() => _isProcessing = true);
    
    // Simulate real network delay for payment processing
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted && widget.trip != null) {
      context.read<BookingCubit>().book(
            tripId: widget.trip!.tripId,
            travelerId: widget.travelerId!,
            seatNumber: widget.seatNumber!,
            driverId: widget.driverId!,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
      ),
      body: BlocListener<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingSuccess) {
            Navigator.pop(context); // Go back to BookingScreen which navigates to QR
          }
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Payment Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Column(
                      children: [
                        _infoRow("Amount to Pay", "${widget.amount} EGP", isBold: true),
                        const Divider(height: 24),
                        _infoRow("Booking Ref", widget.bookingId.substring(0, 8)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text("Choose Payment Method", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _paymentOption(
                    title: "Credit / Debit Card",
                    icon: Icons.credit_card_rounded,
                    color: Colors.blue[700]!,
                    onTap: _processPayment,
                  ),
                  const SizedBox(height: 12),
                  _paymentOption(
                    title: "Mobile Wallet (Vodafone Cash)",
                    icon: Icons.account_balance_wallet_rounded,
                    color: Colors.red[600]!,
                    onTap: _processPayment,
                  ),
                ],
              ),
            ),
            if (_isProcessing)
              Container(
                color: Colors.white.withOpacity(0.9),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: 16),
                      const Text("Processing Payment...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      const Text("Please don't close the app", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.grey)),
        Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 18 : 14, color: AppColors.textDark)),
      ],
    );
  }

  Widget _paymentOption({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: _isProcessing ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}
