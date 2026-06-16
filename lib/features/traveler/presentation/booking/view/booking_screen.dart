import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/entities/trip_entity.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../payment/presentation/cubit/payment_cubit.dart';
import '../../../../payment/presentation/cubit/payment_state.dart';
import '../../../../payment/presentation/pages/payment_webview_page.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';

class BookingScreen extends StatefulWidget {
  final TripEntity trip;
  const BookingScreen({super.key, required this.trip});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    context.read<BookingCubit>().init(widget.trip);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Booking Details",
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocListener<PaymentCubit, PaymentState>(
        listener: (context, state) async {
          if (state is PaymentSuccess) {
            final result = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentWebViewPage(
                  checkoutUrl: state.result.checkoutUrl!,
                  bookingId: 'pending',
                ),
              ),
            );

            if (result == 'success' && context.mounted) {
              _showBookingSuccess(context);
            }
          } else if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocConsumer<BookingCubit, BookingState>(
          listener: (context, state) {
            if (state is BookingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            final bookingState = state is BookingLoaded
                ? state
                : state is BookingLoading
                ? state.previousData
                : null;

            if (bookingState == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final isLoading = state is BookingLoading;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("From", style: TextStyle(color: AppColors.grey)),
                                    Text(bookingState.trip.departurePoint,
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const Icon(Icons.arrow_forward),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text("To", style: TextStyle(color: AppColors.grey)),
                                    Text(bookingState.trip.destinationName,
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _card(
                            child: Column(
                              children: [
                                const Text("Number of Seats"),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: bookingState.selectedSeats > 1
                                          ? () => context.read<BookingCubit>().changeSeats(bookingState.selectedSeats - 1)
                                          : null,
                                      icon: const Icon(Icons.remove),
                                    ),
                                    Column(
                                      children: [
                                        Text("${bookingState.selectedSeats}",
                                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text("${bookingState.trip.availableSeats} seats available",
                                            style: const TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                    IconButton(
                                      onPressed: bookingState.selectedSeats < bookingState.trip.availableSeats
                                          ? () => context.read<BookingCubit>().changeSeats(bookingState.selectedSeats + 1)
                                          : null,
                                      icon: const Icon(Icons.add),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _card(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Base fare (${bookingState.selectedSeats} seats)"),
                                    Text("${bookingState.trip.price * bookingState.selectedSeats} EGP"),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text("${bookingState.total} EGP",
                                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                if (bookingState.trip.depositAmount > 0) ...[
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Deposit Required",
                                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                                      Text("${bookingState.trip.depositAmount} EGP",
                                          style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildPaymentMethodsSection(bookingState, isLoading),
                        ],
                      ),
                    ),
                  ),
                  _buildConfirmButton(context, bookingState, isLoading),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsSection(BookingLoaded bookingState, bool isLoading) {
    if (bookingState.trip.depositAmount <= 0) return const SizedBox();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Choose Payment Method",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            icon: Icons.credit_card,
            title: 'Visa / Mastercard',
            subtitle: 'Pay with credit or debit card',
            method: 'card',
            color: const Color(0xFF1A73E8),
          ),
          const SizedBox(height: 10),
          _buildPaymentOption(
            icon: Icons.phone_android,
            title: 'Orange Cash',
            subtitle: 'Transfer to driver\'s number',
            method: 'orange',
            color: const Color(0xFFFF6D00),
          ),
          const SizedBox(height: 10),
          _buildPaymentOption(
            icon: Icons.phone_android,
            title: 'Vodafone Cash',
            subtitle: 'Transfer to driver\'s number',
            method: 'vodafone',
            color: const Color(0xFFE60000),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String method,
    required Color color,
  }) {
    final isSelected = _selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
                  width: 2,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, BookingLoaded bookingState, bool isLoading) {
    final isDeposit = bookingState.trip.depositAmount > 0;

    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, paymentState) {
        final isPaymentLoading = paymentState is PaymentLoading;

        return AppButton(
          label: isDeposit ? "Confirm & Pay" : "Confirm Booking",
          isLoading: isLoading || isPaymentLoading,
          onPressed: (isLoading || isPaymentLoading) ? null : () {
            if (isDeposit) {
              _handleDepositPayment(context, bookingState);
            } else {
              _confirmBookingDirectly(context, bookingState);
            }
          },
        );
      },
    );
  }

  void _handleDepositPayment(BuildContext context, BookingLoaded bookingState) {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser!;
    final trip = bookingState.trip;
    final deposit = trip.depositAmount;

    if (_selectedPaymentMethod == 'card') {
      _payWithCard(context, deposit, user, trip, bookingState);
    } else {
      _payWithMobileWallet(context, deposit, user, trip, bookingState);
    }
  }

  void _payWithCard(
    BuildContext context,
    double deposit,
    dynamic user,
    TripEntity trip,
    BookingLoaded bookingState,
  ) async {
    final booking = await context.read<BookingCubit>().createPendingBooking(
      tripId: trip.tripId,
      travelerId: user.uid,
      seatNumber: bookingState.selectedSeats,
      driverId: trip.driverId,
      depositAmount: deposit,
    );

    if (booking != null && context.mounted) {
      context.read<PaymentCubit>().createPayment(
        bookingId: booking.bookingId,
        amount: deposit,
        paymentMethod: 'card',
        travelerName: user.displayName ?? 'Traveler',
        travelerPhone: user.phoneNumber ?? '+201000000000',
      );
    }
  }

  void _payWithMobileWallet(
    BuildContext context,
    double deposit,
    dynamic user,
    TripEntity trip,
    BookingLoaded bookingState,
  ) {
    final driverPhone = trip.driverId;
    final methodName = _selectedPaymentMethod == 'orange' ? 'Orange Cash' : 'Vodafone Cash';

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
                color: (_selectedPaymentMethod == 'orange'
                    ? const Color(0xFFFF6D00)
                    : const Color(0xFFE60000))
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.phone_android,
                color: _selectedPaymentMethod == 'orange'
                    ? const Color(0xFFFF6D00)
                    : const Color(0xFFE60000),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pay with $methodName',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Transfer $deposit EGP to the driver\'s number:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    driverPhone,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: driverPhone));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Number copied!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'After transfer, click "I Paid" and the booking will be confirmed.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              _confirmBookingDirectly(context, bookingState);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('I Paid', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmBookingDirectly(BuildContext context, BookingLoaded bookingState) {
    final user = FirebaseAuth.instance.currentUser!;
    context.read<BookingCubit>().book(
      tripId: bookingState.trip.tripId,
      travelerId: user.uid,
      seatNumber: bookingState.selectedSeats,
      driverId: bookingState.trip.driverId,
    );
  }

  void _showBookingSuccess(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Your booking is confirmed. The driver will see your booking.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8)],
      ),
      child: child,
    );
  }
}
