import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/router/app_router.dart';
import '../cubit/states.dart';
import '../cubit/traveler_cubit.dart';

class TripsScreen extends StatefulWidget {
  final String destinationId;

  const TripsScreen({super.key, required this.destinationId});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TravelerCubit>().loadTrips(widget.destinationId);
  }

  @override
  Widget build(BuildContext context) {
    // ثيم الألوان الموحد للمشروع بناءً على الموك
    const primaryColor = Color(0xFF91A896); // الأخضر الهادي
    const textColor = Color(0xFF1E3A5F);    // الأزرق الغامق للكتابة

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // خلفية فاتحة مريحة للعين
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Available Trips",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: BlocBuilder<TravelerCubit, TravelerState>(
        builder: (context, state) {
          if (state is TripsLoading) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          if (state is TripsError) {
            return Center(
              child: Text(
                "Error: ${state.message}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is TripsLoaded) {
            if (state.trips.isEmpty) {
              return const Center(
                child: Text(
                  "No Trips Found for this Destination",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: state.trips.length,
              itemBuilder: (context, index) {
                final trip = state.trips[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.booking,
                        arguments: {
                          "tripId": trip.tripId,
                          "price": trip.price,
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // الصف العلوي: اسم الوجهة وحالة الرحلة (Status)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                trip.destinationName,
                                style: const TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: trip.status == "active" || trip.status == "available"
                                      ? const Color(0xFFE8F5E9)
                                      : const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  trip.status.toUpperCase(),
                                  style: TextStyle(
                                    color: trip.status == "active" || trip.status == "available"
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // نقطة الانطلاق
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, color: Colors.grey, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                "Departure: ${trip.departurePoint}",
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1, color: Color(0xFFF1F3F4)),
                          ),

                          // الصف السفلي: السعر والمقاعد المتاحة
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // المقاعد المتاحة
                              Row(
                                children: [
                                  const Icon(Icons.event_seat_outlined, color: primaryColor, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${trip.availableSeats} seats left",
                                    style: const TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              // السعر
                              Text(
                                "${trip.price} EGP",
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(child: Text("No Trips"));
        },
      ),
    );
  }
}