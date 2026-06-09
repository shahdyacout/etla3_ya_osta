import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SnackbarHelper {
  SnackbarHelper._();

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, AppColors.primary);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, Colors.redAccent);
  }


  static void _show(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}