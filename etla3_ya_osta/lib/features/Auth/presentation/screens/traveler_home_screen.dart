
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../provider/auth_provider.dart';

class TravelerHomeScreen extends ConsumerWidget {
  const TravelerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Masar',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textLight),
            onPressed: () => _onLogout(context, ref),
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRouter.ratingScreen,
              arguments: {
                'tripId': 'trip_123',
                'driverName': 'Mohamed Ahmed',
              },
            );
          },
          child: const Text(
            'Test Rating Screen',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<void> _onLogout(BuildContext context, WidgetRef ref) async {
    // بنعمل logout من الـ provider
    await ref.read(authProvider.notifier).logout();

    if (!context.mounted) return;

    // بنمسح الـ stack كامل ونرجع للـ splash
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.splash,
      (route) => false,
    );
  }
}