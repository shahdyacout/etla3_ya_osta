import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrScreen extends StatelessWidget {
  final String bookingId;

  const QrScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF91A896);
    const textColor = Color(0xFF1E3A5F);
    const darkButtonColor = Color(0xFF2C3E50);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // الإشعار الأخضر العلوي (Booking confirmed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFC8E6C9)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text("Booking confirmed! Proceed to check-in.", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const Spacer(),

            // نصوص العناوين
            const Text("Ready to Board", style: TextStyle(color: primaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text("Show this QR code to the driver", style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 24),

            // كارت الـ QR الرئيسي 흰색
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  // الـ QR Code الفعلي
                  QrImageView(
                    data: bookingId,
                    size: 180,
                    embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(40, 40)),
                  ),
                  const SizedBox(height: 16),
                  const Text("Booking ID", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  // كود تجريبي من الصورة
                  const Text("MSR-9HCK1Z", style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // مربع الملاحظة الرمادي السفلية
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: const Color(0xFFEAECEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "The driver will scan this code to verify your booking and assign your seat.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            const Spacer(),

            // زرار View Route Guide
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkButtonColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // الانتقال لشاشة الـ Live Directions لاحقاً
                  },
                  icon: const Icon(Icons.navigation_outlined, color: Colors.white, size: 18),
                  label: const Text("View Route Guide", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}