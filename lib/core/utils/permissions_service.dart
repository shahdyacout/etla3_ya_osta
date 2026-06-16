import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';

class PermissionsService {
  static Future<void> requestPermissions() async {
    await _requestLocationPermission();
    await _requestNotificationPermission();
  }

  static Future<void> _requestLocationPermission() async {
    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  static Future<void> _requestNotificationPermission() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}