import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../cubit/driver_cubit.dart';
import '../cubit/driver_state.dart';

class TripInProgressScreen extends StatelessWidget {
  const TripInProgressScreen({super.key});

  static const Color primarySage = Color(0xFF9BB59A);
  static const Color darkText = Color(0xFF2F4054);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Trip In Progress",
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<DriverCubit, DriverState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildTripStatusCard(state),
                const SizedBox(height: 20),
                _buildStatsGrid(state),
                const Spacer(),
                _buildEndTripButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTripStatusCard(DriverState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.directions_bus, color: primarySage, size: 48),
          const SizedBox(height: 16),
          const Text(
            "Cairo Central → Alexandria",
            style: TextStyle(
              color: darkText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Current Station: Cairo Central",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _tripInfoItem(Icons.people, "${state.occupiedSeats}", "Passengers"),
              _tripInfoItem(Icons.timer, "00:15", "Duration"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tripInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: primarySage, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildStatsGrid(DriverState state) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _statCard("Current Earnings", "${state.occupiedSeats * 50} EGP"),
        _statCard("Next Stop", "Banha"),
      ],
    );
  }

  Widget _statCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkText)),
        ],
      ),
    );
  }

  Widget _buildEndTripButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          context.read<DriverCubit>().endTrip();
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.tripSummary,
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE57373),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          "End Trip",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
