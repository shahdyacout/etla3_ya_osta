import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TravelerHomeScreen extends StatelessWidget {
  const TravelerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: Text(
          'Traveler Home 🧳',
          style: TextStyle(
            fontSize: 24,
            color: AppColors.textDark,
          ),
        ),
      ),
    );
  }
}