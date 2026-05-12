import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
}