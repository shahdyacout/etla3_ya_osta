import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../Auth/presentation/cubit/auth_cubit.dart';
import '../../../../core/router/app_router.dart';
import '../cubit/driver_cubit.dart';
import '../cubit/driver_state.dart';
import 'qr_scanner_dialog.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen>
    with TickerProviderStateMixin {
  static const Color primarySage = Color(0xFF9BB59A);
  static const Color darkText = Color(0xFF2F4054);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color coralRed = Color(0xFFE57373);

  late AnimationController _bannerController;
  late Animation<double> _bannerFade;
  late Animation<Offset> _bannerSlide;

  late AnimationController _queueController;
  late Animation<double> _queueFade;
  late Animation<Offset> _queueSlide;

  bool _showSuccessBanner = false;

  @override
  void initState() {
    super.initState();
    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bannerFade = CurvedAnimation(
      parent: _bannerController,
      curve: Curves.easeIn,
    );
    _bannerSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _bannerController,
      curve: Curves.easeOutCubic,
    ));

    _queueController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _queueFade = CurvedAnimation(
      parent: _queueController,
      curve: Curves.easeIn,
    );
    _queueSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _queueController,
      curve: Curves.easeOutBack,
    ));

    final driverId = FirebaseAuth.instance.currentUser?.uid ?? 'mock_driver_id';
    context.read<DriverCubit>().initDriver(driverId);
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _queueController.dispose();
    super.dispose();
  }

  void _onStatusChanged(bool isOnline) {
    if (isOnline) {
      setState(() => _showSuccessBanner = true);
      _bannerController.forward(from: 0);
      _queueController.forward(from: 0);

      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          _bannerController.reverse().then((_) {
            if (mounted) setState(() => _showSuccessBanner = false);
          });
        }
      });
    } else {
      _queueController.reverse();
      setState(() => _showSuccessBanner = false);
    }
  }

  void _showSeatCountDialog(BuildContext context) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
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
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primarySage.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.airline_seat_recline_normal, color: primarySage, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        "Start Boarding",
                        style: TextStyle(
                          color: darkText,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "How many seats are currently available?",
                  style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 16,
                    color: darkText,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter seat count",
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.4)),
                    filled: true,
                    fillColor: lightBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: primarySage, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.redAccent),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter a number";
                    }
                    final number = int.tryParse(value.trim());
                    if (number == null) {
                      return "Please enter a valid number";
                    }
                    if (number <= 0) {
                      return "Must be greater than 0";
                    }
                    if (number > 14) {
                      return "Must not exceed 14";
                    }
                    return null;
                  },
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
                              side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                            ),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final seats = int.parse(controller.text.trim());
                              Navigator.pop(dialogContext);
                              context.read<DriverCubit>().startBoarding(seats);
                              Navigator.pushNamed(context, AppRouter.passengerLoading);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primarySage,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Confirm",
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          "Smart Microbus Management App",
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<DriverCubit, DriverState>(
        listenWhen: (prev, curr) => prev.isOnline != curr.isOnline,
        listener: (context, state) {
          _onStatusChanged(state.isOnline);
        },
        builder: (context, state) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              children: [
                if (_showSuccessBanner) ...[
                  _buildSuccessBanner(),
                  const SizedBox(height: 16),
                ],
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: state.isOnline
                      ? _buildOnlineStatusCard(context, state)
                      : _buildOfflineStatusCard(context, state),
                ),
                const SizedBox(height: 20),
                if (state.isOnline) ...[
                  FadeTransition(
                    opacity: _queueFade,
                    child: SlideTransition(
                      position: _queueSlide,
                      child: _buildQueuePositionCard(state),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                _buildPerformanceCard(state),
                const SizedBox(height: 24),
                _buildBottomButtons(context, state),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return SlideTransition(
      position: _bannerSlide,
      child: FadeTransition(
        opacity: _bannerFade,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: successGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: successGreen.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: successGreen,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                "You are now online!",
                style: TextStyle(
                  color: successGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineStatusCard(BuildContext context, DriverState state) {
    return Container(
      key: const ValueKey('offline_card'),
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Go Online",
            style: TextStyle(
              color: darkText,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Start accepting ride requests",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: state.isLoading ? null : () => context.read<DriverCubit>().goOnline(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primarySage,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: state.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.power_settings_new, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Go Online",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineStatusCard(BuildContext context, DriverState state) {
    return Container(
      key: const ValueKey('online_card'),
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "You're Online",
            style: TextStyle(
              color: darkText,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Ready to accept rides",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: state.isLoading ? null : () => context.read<DriverCubit>().goOffline(),
              style: ElevatedButton.styleFrom(
                backgroundColor: coralRed,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: state.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.power_settings_new, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Go Offline",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueuePositionCard(DriverState state) {
    bool isReady = state.queuePosition == 1;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isReady ? Icons.check_circle_outline : Icons.group_outlined,
            color: isReady ? successGreen : Colors.grey,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            isReady ? "Your vehicle is ready for boarding" : "Queue Position",
            style: TextStyle(
              color: isReady ? successGreen : Colors.grey,
              fontSize: 14,
              fontWeight: isReady ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "#${state.queuePosition == 0 ? 4 : state.queuePosition}",
            style: const TextStyle(
              color: primarySage,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "in Cairo Central Station",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          if (isReady)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => _showSeatCountDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primarySage,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Start Boarding",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Estimated wait: ~32 minutes",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(DriverState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Performance",
            style: TextStyle(
              color: darkText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _buildStatItem(
                icon: Icons.trending_up,
                value: state.completedTrips.toString(),
                label: "Completed Trips",
              ),
              _buildStatItem(
                icon: Icons.account_balance_wallet_outlined,
                value: "${state.totalEarnings.toStringAsFixed(0)} EGP",
                label: "Total Earnings",
              ),
              _buildStatItem(
                icon: Icons.access_time,
                value: DurationFormatter.fromMinutes(state.totalActiveMinutes),
                label: "Active Hours",
              ),
              _buildStatItem(
                icon: Icons.group_outlined,
                value: "${state.avgRating}★",
                label: "Avg Rating",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: primarySage, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: darkText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, DriverState state) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: "QR Scanner",
            onPressed: state.isOnline ? () {
              showDialog(
                context: context,
                builder: (_) => BlocProvider.value(
                  value: context.read<DriverCubit>(),
                  child: const QrScannerDialog(),
                ),
              );
            } : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            label: "View Wallet",
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isEnabled ? Colors.grey.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isEnabled ? darkText : Colors.grey.withOpacity(0.5),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
