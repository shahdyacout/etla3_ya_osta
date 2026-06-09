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

  const BookingScreen({
    super.key,
    required this.trip,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int seatCount = 1;

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
          if (state is BookingSuccess) {
            Navigator.pushNamed(
              context,
              AppRouter.qr,
              arguments: state.booking,
            );
          }

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
            return const Center(
              child: CircularProgressIndicator(),
            );
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
                                  const Text(
                                    "From",
                                    style: TextStyle(color: AppColors.grey),
                                  ),
                                  Text(
                                    bookingState.trip.departurePoint,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(Icons.arrow_forward),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    "To",
                                    style: TextStyle(color: AppColors.grey),
                                  ),
                                  Text(
                                    bookingState.trip.destinationName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
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
                              const Text("Number of Seats"),

                              const SizedBox(height: 10),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: seatCount > 1
                                        ? () {
                                      setState(() => seatCount--);

                                      context
                                          .read<BookingCubit>()
                                          .changeSeats(seatCount);
                                    }
                                        : null,
                                    icon: const Icon(Icons.remove),
                                  ),

                                  Text(
                                    "$seatCount",
                                    style: const TextStyle(fontSize: 20),
                                  ),

                                  IconButton(
                                    onPressed: () {
                                      setState(() => seatCount++);

                                      context
                                          .read<BookingCubit>()
                                          .changeSeats(seatCount);
                                    },
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
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Base fare ($seatCount seats)",
                                  ),
                                  Text(
                                    "${bookingState.trip.price * seatCount} EGP",
                                  ),
                                ],
                              ),

                              const Divider(),

                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Total",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${bookingState.total} EGP",
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                AppButton(
                  label: "Confirm Booking",
                  isLoading: isLoading,
                  onPressed: isLoading
                      ? null
                      : () {
                    context.read<BookingCubit>().book(
                      tripId: bookingState.trip.tripId,
                      travelerId: "user123",
                      seatNumber: seatCount,
                    );
                  },
                ),
              ],
            ),
          );
        },
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
          ),
        ],
      ),
      child: child,
    );
  }
}