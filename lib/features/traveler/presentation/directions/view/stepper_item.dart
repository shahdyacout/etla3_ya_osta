import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/direction_step.dart';

class StepperItem extends StatelessWidget {
  final DirectionStep step;

  const StepperItem({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    final bool isDone = step.status == 'done';
    final bool isCurrent = step.status == 'current';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFF8F9FA) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            // Icon Circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.primary
                    : (isDone ? const Color(0xFFDDE7E1) : const Color(0xFFF1F3F5)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDone
                    ? Icons.check_rounded
                    : (step.text.contains("Bus")
                        ? Icons.location_on_rounded
                        : Icons.arrow_forward_rounded),
                color: isCurrent
                    ? Colors.white
                    : (isDone ? AppColors.primary : const Color(0xFFADB5BD)),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            // Text Content
            Expanded(
              child: Text(
                step.text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                  color: isDone ? const Color(0xFFADB5BD) : AppColors.textDark,
                  decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
            ),
            // Status Badge or Distance
            if (isCurrent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937), // Dark Charcoal/Navy
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Current",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (!isDone && step.distance != "0m")
              Text(
                step.distance,
                style: const TextStyle(
                  color: Color(0xFFADB5BD),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
