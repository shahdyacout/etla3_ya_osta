import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/entities/trip_entity.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_button.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';

class BookingScreen extends StatefulWidget {
  final TripEntity trip;
  const BookingScreen({super.key, required this.trip});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
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
      body: BlocConsumer<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is BookingSuccess) {
            Navigator.pushReplacementNamed(
              context,
              AppRouter.qr,
              arguments: state.booking,
            );
          }
        },
        builder: (context, state) {
          final bookingState = state is BookingLoaded
              ? state
              : state is BookingLoading
              ? state.previousData
              : null;

          if (bookingState == null && state is! BookingSuccess) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BookingSuccess) {
            return const SizedBox();
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
                                  Text(bookingState!.trip.departurePoint,
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
                                        ? () {
                                      context.read<BookingCubit>().changeSeats(bookingState.selectedSeats - 1);
                                    }
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
                                        ? () {
                                      context.read<BookingCubit>().changeSeats(bookingState.selectedSeats + 1);
                                    }
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
                      ],
                    ),
                  ),
                ),
                AppButton(
                  label: bookingState.trip.depositAmount > 0 ? "Confirm & Pay Deposit" : "Confirm Booking",
                  isLoading: isLoading,
                  onPressed: isLoading
                      ? null
                      : () {
                    final deposit = bookingState.trip.depositAmount;
                    if (deposit > 0) {
                      _showDepositConfirmDialog(context, bookingState);
                    } else {
                      final user = FirebaseAuth.instance.currentUser!;
                      context.read<BookingCubit>().book(
                        tripId: bookingState.trip.tripId,
                        travelerId: user.uid,
                        seatNumber: bookingState.selectedSeats,
                        driverId: bookingState.trip.driverId,
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDepositConfirmDialog(BuildContext context, BookingLoaded bookingState) {
    final user = FirebaseAuth.instance.currentUser!;
    final trip = bookingState.trip;
    final totalSeats = bookingState.selectedSeats;
    final totalFare = trip.price * totalSeats;
    final deposit = trip.depositAmount;
    final total = totalFare + deposit;

    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(77),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.payment, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      "Confirm Deposit Payment",
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildDialogRow("Route", "${trip.departurePoint} → ${trip.destinationName}"),
                    const SizedBox(height: 8),
                    _buildDialogRow("Seats", "$totalSeats seat(s)"),
                    const SizedBox(height: 8),
                    _buildDialogRow("Base Fare", "${totalFare.toStringAsFixed(0)} EGP"),
                    const Divider(height: 20),
                    _buildDialogRow(
                      "Deposit Required",
                      "${deposit.toStringAsFixed(0)} EGP",
                      valueColor: Colors.orange,
                    ),
                    const Divider(height: 20),
                    _buildDialogRow(
                      "Total",
                      "${total.toStringAsFixed(0)} EGP",
                      isBold: true,
                      valueColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Deposit will be refunded after trip completion or deducted if cancelled.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[800],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.withAlpha(50)),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          final user = FirebaseAuth.instance.currentUser!;
                          final booking = await context.read<BookingCubit>().createPendingBooking(
                            tripId: trip.tripId,
                            travelerId: user.uid,
                            seatNumber: totalSeats,
                            driverId: trip.driverId,
                            depositAmount: deposit,
                          );
                          if (booking != null && context.mounted) {
                            Navigator.pushNamed(
                              context,
                              AppRouter.payment,
                              arguments: {
                                'bookingId': booking.bookingId,
                                'amount': deposit,
                                'travelerName': user.displayName ?? 'Traveler',
                                'travelerPhone': user.phoneNumber ?? '+201000000000',
                                'trip': trip,
                                'travelerId': user.uid,
                                'seatNumber': totalSeats,
                                'driverId': trip.driverId,
                              },
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Pay Deposit",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.textDark,
          ),
        ),
      ],
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
