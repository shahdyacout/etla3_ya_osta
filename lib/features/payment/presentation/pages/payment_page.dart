import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/entities/trip_entity.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../traveler/presentation/booking/cubit/booking_cubit.dart';
import '../../../traveler/presentation/booking/cubit/booking_state.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import 'payment_webview_page.dart';

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
  String? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final trip = widget.trip;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: BlocListener<PaymentCubit, PaymentState>(
        listener: (context, state) async {
          if (state is PaymentSuccess) {
            final result = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentWebViewPage(
                  checkoutUrl: state.result.checkoutUrl!,
                  bookingId: widget.bookingId,
                ),
              ),
            );

            if (result == 'success' && context.mounted) {
              await context.read<BookingCubit>().confirmBooking(widget.bookingId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment successful! Booking confirmed.'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            } else if (result == 'failure' && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment failed. Please try again.'),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (result == 'cancelled' && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment cancelled.'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          } else if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocListener<BookingCubit, BookingState>(
          listener: (context, state) {
            if (state is BookingSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking confirmed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.popUntil(context, (route) => route.isFirst);
            } else if (state is BookingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (trip != null) ...[
                  _buildTripSummaryCard(trip, isSmallScreen),
                  const SizedBox(height: 16),
                ],
                _buildAmountCard(isSmallScreen),
                SizedBox(height: isSmallScreen ? 20 : 24),
                const Text(
                  'Select Payment Method',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                _buildPaymentMethodCard(
                  context,
                  icon: Icons.credit_card,
                  title: 'Visa / Mastercard',
                  subtitle: 'Pay with credit or debit card',
                  method: 'card',
                  color: const Color(0xFF1A73E8),
                  isSmallScreen: isSmallScreen,
                ),
                const SizedBox(height: 12),
                _buildPaymentMethodCard(
                  context,
                  icon: Icons.phone_android,
                  title: 'Mobile Wallet',
                  subtitle: 'Vodafone Cash, Orange Money, etc.',
                  method: 'cash',
                  color: const Color(0xFFE53935),
                  isSmallScreen: isSmallScreen,
                ),
                const SizedBox(height: 24),
                BlocBuilder<PaymentCubit, PaymentState>(
                  builder: (context, state) {
                    final isLoading = state is PaymentLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: (isLoading || _selectedMethod == null)
                            ? null
                            : () => _processPayment(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: Colors.grey[300],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Pay Now',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Secured by Paymob',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripSummaryCard(TripEntity trip, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_bus,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Trip Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'Route',
            '${trip.departurePoint} → ${trip.destinationName}',
          ),
          const SizedBox(height: 10),
          _buildSummaryRow(
            'Seats',
            '${widget.seatNumber ?? 1} seat(s)',
          ),
          const SizedBox(height: 10),
          _buildSummaryRow(
            'Price per seat',
            '${trip.price.toStringAsFixed(0)} EGP',
          ),
          if (trip.depositAmount > 0) ...[
            const SizedBox(height: 10),
            _buildSummaryRow(
              'Deposit',
              '${trip.depositAmount.toStringAsFixed(0)} EGP',
              valueColor: Colors.orange,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountCard(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(77),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Amount to Pay',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.amount.toStringAsFixed(0)} EGP',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Booking: ${widget.bookingId.substring(0, widget.bookingId.length > 15 ? 15 : widget.bookingId.length)}...',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String method,
    required Color color,
    required bool isSmallScreen,
  }) {
    final isSelected = _selectedMethod == method;
    final isLoading = context.watch<PaymentCubit>().state is PaymentLoading;

    return GestureDetector(
      onTap: isLoading
          ? null
          : () {
              setState(() => _selectedMethod = method);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(13) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withAlpha(30),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withAlpha(25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : Colors.grey.withAlpha(60),
                  width: 2,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textDark,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  void _processPayment(BuildContext context) {
    if (_selectedMethod == null) return;

    if (_selectedMethod == 'cash') {
      _showComingSoonDialog(context);
      return;
    }

    context.read<PaymentCubit>().createPayment(
          bookingId: widget.bookingId,
          amount: widget.amount,
          paymentMethod: _selectedMethod!,
          travelerName: widget.travelerName,
          travelerPhone: widget.travelerPhone,
        );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_android,
                color: Color(0xFFE53935),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vodafone Cash, Orange Money, and Etisalat Cash will be available soon.\n\nPlease use Visa/Mastercard for now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
