import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../router/app_router.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentDriverId;
  
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> initialize() async {
    // 1. Request Permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // 2. Handle Token Refresh
    _fcm.onTokenRefresh.listen((newToken) async {
      if (_currentDriverId != null) {
        await _saveTokenToFirestore(_currentDriverId!, newToken);
      }
    });

    // 3. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showForegroundSnackbar(message);
      }
    });

    // 4. Handle Background/Terminated Click
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);

    // 5. Handle Initial Message (if app was terminated)
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClick(initialMessage);
    }
  }

  Future<void> saveToken(String driverId) async {
    _currentDriverId = driverId;
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        await _saveTokenToFirestore(driverId, token);
      }
    } catch (e) {
      print("Error saving FCM token: $e");
    }
  }

  Future<void> _saveTokenToFirestore(String driverId, String token) async {
    await _firestore.collection('drivers').doc(driverId).set({
      'fcmToken': token,
    }, SetOptions(merge: true));
    print("FCM Token saved for driver $driverId");
  }

  void _handleNotificationClick(RemoteMessage message) {
    final String? type = message.data['type'];
    if (type == null) return;

    switch (type) {
      case 'assignment_ready':
      case 'queue_updated':
        navigatorKey.currentState?.pushNamed(AppRouter.driverHome);
        break;
      case 'boarding_started':
        navigatorKey.currentState?.pushNamed(AppRouter.passengerLoading);
        break;
      case 'trip_started':
        navigatorKey.currentState?.pushNamed(AppRouter.tripInProgress);
        break;
      case 'trip_completed':
        navigatorKey.currentState?.pushNamed(AppRouter.tripSummary);
        break;
    }
  }

  void _showForegroundSnackbar(RemoteMessage message) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message.notification?.title ?? "New Notification", 
                style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(message.notification?.body ?? ""),
            ],
          ),
          action: SnackBarAction(
            label: 'View',
            onPressed: () => _handleNotificationClick(message),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
