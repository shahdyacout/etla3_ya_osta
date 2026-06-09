import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../cubit/auth_cubit.dart';

class TravelerHomeScreen extends StatelessWidget {
  const TravelerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => _onLogout(context),
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
              arguments: {'tripId': 'trip_123', 'driverName': 'Mohamed Ahmed'},
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

  Future<void> _onLogout(BuildContext context) async {
    await context.read<AuthCubit>().logout();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.roleSelection,
      (route) => false,
    );
  }
}
