import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../provider/auth_provider.dart';

class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});

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
      body: const Center(
        child: Text(
          'Driver Home 🚐',
          style: TextStyle(
            fontSize: 24,
            color: AppColors.textDark,
          ),
        ),
      ),
    );
  }

  Future<void> _onLogout(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).logout();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.splash,
      (route) => false,
    );
  }
}