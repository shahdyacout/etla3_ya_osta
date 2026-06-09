import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/router/app_router.dart';
import '../cubit/states.dart';
import '../cubit/traveler_cubit.dart';

class BookingScreen extends StatefulWidget {
  final String tripId;
  final int price;

  const BookingScreen({
    super.key,
    required this.tripId,
    required this.price,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int seatCount = 1; // عداد المقاعد الافتراضي

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF91A896);
    const textColor = Color(0xFF1E3A5F);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Booking Details", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
      body: BlocConsumer<TravelerCubit, TravelerState>(
        listener: (context, state) {
          if (state is BookingSuccess) {
            Navigator.pushNamed(context, AppRouter.qr, arguments: widget.tripId);
          }
          if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Booking Error: ${state.message}")),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // 1. كارت خط السير
                        _buildCard(
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("From", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  Text("Cairo Central", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Icon(Icons.more_horiz, color: Colors.grey),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("To", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  Text("Tanta", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 2. كارت تفاصيل السائق والعربية
                        _buildCard(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: primaryColor.withOpacity(0.1),
                                    child: const Icon(Icons.directions_car, color: primaryColor),
                                  ),
                                  const SizedBox(width: 12),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("ABC 1234", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text("Ahmed Hassan", style: TextStyle(color: Colors.grey, fontSize: 14)),
                                    ],
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: const Color(0xFFF1F3F4), borderRadius: BorderRadius.circular(12)),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.star, color: textColor, size: 16),
                                        SizedBox(width: 4),
                                        Text("4.9", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const Divider(height: 24),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, color: Colors.grey, size: 18),
                                      SizedBox(width: 6),
                                      Text("ETA\n12 min", style: TextStyle(color: textColor, fontSize: 12)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_border_rounded, color: Colors.grey, size: 18), // أو Icons.verified_outlined                                      SizedBox(width: 6),
                                      Text("Condition\nExcellent", style: TextStyle(color: textColor, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 3. كارت العداد المقاعد
                        _buildCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.people_outline, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text("Number of Seats", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildCounterButton(Icons.remove, () {
                                    if (seatCount > 1) setState(() => seatCount--);
                                  }),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: Text("$seatCount", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                                  ),
                                  _buildCounterButton(Icons.add, () {
                                    setState(() => seatCount++);
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 4. كارت الحساب المالي
                        _buildCard(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Base fare ($seatCount seats)", style: const TextStyle(color: Colors.grey)),
                                  Text("${widget.price * seatCount} EGP", style: const TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Total", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text("${widget.price * seatCount} EGP", style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // زرار التأكيد الكبير السفلي
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: state is BookingLoading
                        ? null
                        : () {
                      context.read<TravelerCubit>().book(
                        tripId: widget.tripId,
                        travelerId: "user123",
                        seatNumber: seatCount,
                      );
                    },
                    child: state is BookingLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Confirm Booking", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(color: Color(0xFFE5E9E8), shape: BoxShape.circle),
        child: Icon(icon, color: const Color(0xFF1E3A5F), size: 20),
      ),
    );
  }
}