import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../cubit/driver_cubit.dart';
import '../cubit/driver_state.dart';
import 'qr_scanner_dialog.dart';

class PassengerLoadingScreen extends StatefulWidget {
  const PassengerLoadingScreen({super.key});

  @override
  State<PassengerLoadingScreen> createState() => _PassengerLoadingScreenState();
}

class _PassengerLoadingScreenState extends State<PassengerLoadingScreen>
    with SingleTickerProviderStateMixin {
  static const Color primarySage = Color(0xFF9BB59A);
  static const Color darkText = Color(0xFF2F4054);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color lightBackground = Color(0xFFF9F9F9);

  late AnimationController _bannerController;
  late Animation<double> _bannerFade;
  late Animation<Offset> _bannerSlide;

  @override
  void initState() {
    super.initState();
    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bannerFade = CurvedAnimation(parent: _bannerController, curve: Curves.easeIn);
    _bannerSlide = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _bannerController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  void _showBanner() {
    _bannerController.forward(from: 0);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _bannerController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Passenger Loading",
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<DriverCubit, DriverState>(
        listenWhen: (prev, curr) => prev.occupiedSeats != curr.occupiedSeats || prev.verificationMessage != curr.verificationMessage,
        listener: (context, state) {
          if (state.verificationMessage != null) {
            _showBanner();
          }
        },
        builder: (context, state) {
          final isFull = state.occupiedSeats >= 14;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildLoadingProgressCard(state),
                    const SizedBox(height: 20),
                    _buildSeatOccupancyCard(state),
                    const SizedBox(height: 32),
                    _buildBottomAction(context, state, isFull),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              _buildStatusBanner(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusBanner(DriverState state) {
    final bool success = state.verificationSuccess ?? true;
    final Color color = success ? successGreen : Colors.redAccent;

    return Positioned(
      top: 10,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _bannerSlide,
        child: FadeTransition(
          opacity: _bannerFade,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(success ? Icons.check_circle : Icons.error, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.verificationMessage ?? "",
                    style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingProgressCard(DriverState state) {
    double progress = state.occupiedSeats / 14;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: primarySage.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.person_outline, color: primarySage, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Passenger Loading",
                        style: TextStyle(color: darkText, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("${state.occupiedSeats}/14",
                        style: const TextStyle(color: primarySage, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.withOpacity(0.1),
              color: primarySage,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            state.occupiedSeats >= 14 ? "Microbus Fully Loaded - Ready To Start Trip" : "Scan passenger QR codes to check them in",
            style: TextStyle(color: state.occupiedSeats >= 14 ? successGreen : Colors.grey, fontSize: 13, fontWeight: state.occupiedSeats >= 14 ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatOccupancyCard(DriverState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Seat Occupancy",
                  style: TextStyle(color: darkText, fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: darkText, borderRadius: BorderRadius.circular(8)),
                child: const Text("Driver",
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 14,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, index) {
              int seatNum = index + 1;
              bool isOccupied = seatNum <= state.occupiedSeats;
              return _buildSeatItem(seatNum, isOccupied);
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(successGreen, "Occupied"),
              const SizedBox(width: 24),
              _buildLegend(Colors.grey.withOpacity(0.2), "Empty"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeatItem(int seatNum, bool isOccupied) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween<double>(begin: 1.0, end: isOccupied ? 1.05 : 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(
              color: isOccupied ? successGreen.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isOccupied ? successGreen.withOpacity(0.2) : Colors.transparent),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isOccupied ? Icons.check_circle : Icons.chair_outlined,
                    key: ValueKey(isOccupied),
                    color: isOccupied ? successGreen : Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Seat $seatNum",
                  style: TextStyle(
                    color: isOccupied ? successGreen : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildBottomAction(BuildContext context, DriverState state, bool isFull) {
    if (isFull) {
      return Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: successGreen, size: 20),
              SizedBox(width: 8),
              Text(
                "✓ Microbus Fully Loaded",
                style: TextStyle(color: successGreen, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _largeButton(
            text: "Start Trip",
            color: primarySage,
            isLoading: state.isLoading,
            onPressed: () {
              context.read<DriverCubit>().startTrip();
              Navigator.pushNamedAndRemoveUntil(context, AppRouter.tripInProgress, (route) => false);
            },
          ),
        ],
      );
    }

    return _largeButton(
      text: "Open QR Scanner",
      color: primarySage,
      isLoading: state.isLoading || state.isVerifying,
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => BlocProvider.value(
            value: context.read<DriverCubit>(),
            child: const QrScannerDialog(),
          ),
        );
      },
    );
  }

  Widget _largeButton({required String text, required Color color, required VoidCallback onPressed, bool isLoading = false}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      );
}
