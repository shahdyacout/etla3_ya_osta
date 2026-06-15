import 'package:flutter/material.dart';

import '../../../domain/entities/direction_step.dart';

class StepperItem extends StatelessWidget {
  final DirectionStep step;

  const StepperItem({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    // تحديد الألوان والخلفيات بناءً على حالة الخطوة
    final bool isDone = step.status == 'done';
    final bool isCurrent = step.status == 'current';

    Color cardBgColor = Colors.white;
    Color iconBgColor = const Color(0xFFE9ECEF);
    Color iconColor = const Color(0xFF6C757D);
    IconData iconData = Icons.arrow_forward_rounded;
    double cardElevation = 0.5;

    if (isDone) {
      cardBgColor = const Color(0xFFF1F3F5); // خلفية رمادية خفيفة للخطوات المنتهية
      iconBgColor = const Color(0xFFD3E2D8); // دائرة خضراء هادية
      iconColor = const Color(0xFF52796F);
      iconData = Icons.check_rounded;
    } else if (isCurrent) {
      cardBgColor = const Color(0xFFF4F7F6); // خلفية مائلة للأخضر خفيف جداً
      iconBgColor = const Color(0xFF84A59D); // اللون الزيتي الهادي اللي في الصورة
      iconColor = Colors.white;
      cardElevation = 2.0; // رفع الكارت الحالي خفيفاً بـ Shadow ناعم
    } else if (step.text.contains("Bus")) {
      iconData = Icons.location_on_rounded; // أيقونة اللوكيشن لخطوة الأوتوبيس الأخيرة
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isCurrent ? 0.06 : 0.02),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isCurrent ? const Color(0xFFE0E7E5) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            // الدائرة اللي جواها الأيقونة على الشمال
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            // نصوص وتفاصيل الخطوة
            Expanded(
              child: Text(
                step.text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                  color: isDone ? const Color(0xFFADB5BD) : const Color(0xFF343A40),
                  // عمل خط مشطوب لو الخطوة خلصت (Line-through)
                  decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
            ),
            // الـ Badge بتاع Current أو المسافة على اليمين
            if (isCurrent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937), // اللون الكحلي الغامق للـ Badge
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Current",
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              )
            else if (!isDone && step.distance != "0m")
              Text(
                step.distance,
                style: const TextStyle(
                  color: Color(0xFF6C757D),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}