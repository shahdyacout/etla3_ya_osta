import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/router/app_router.dart';
import '../cubit/driver_cubit.dart';
import '../cubit/driver_state.dart';

class TripSummaryScreen extends StatelessWidget {
  const TripSummaryScreen({super.key});

  static const Color primarySage = Color(0xFF9BB59A);
  static const Color darkText = Color(0xFF2F4054);
  static const Color successGreen = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<DriverCubit, DriverState>(
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: successGreen, size: 80),
                  const SizedBox(height: 16),
                  const Text(
                    "Trip Completed!",
                    style: TextStyle(
                      color: darkText,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Great job! Here's your summary for this trip.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  _buildSummaryCard(state),
                  const Spacer(),
                  _buildHomeButton(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(DriverState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _summaryRow("Total Passengers", "${state.occupiedSeats}"),
          const Divider(height: 32),
          _summaryRow("Total Earnings", "${state.occupiedSeats * 50} EGP"),
          const Divider(height: 32),
          _summaryRow("Trip Duration", "24 minutes"),
          const Divider(height: 32),
          _summaryRow("New Rating", "5.0 ★"),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        Text(value, style: const TextStyle(color: darkText, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildHomeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          context.read<DriverCubit>().resetToHome();
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.driverHome,
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primarySage,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          "Back To Home",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
