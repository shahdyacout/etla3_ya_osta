import 'package:etla3_ya_osta/features/Auth/presentation/screens/driver_home_screen.dart';
import 'package:etla3_ya_osta/features/Auth/presentation/screens/otp_screen.dart';
import 'package:etla3_ya_osta/features/Auth/presentation/screens/phone_input_screen.dart';
import 'package:etla3_ya_osta/features/Auth/presentation/screens/rating_screen.dart';
import 'package:etla3_ya_osta/features/Auth/presentation/screens/role_selection_screen.dart';
import 'package:flutter/material.dart';

import '../../features/traveler/presentation/booking/view/booking_screen.dart';
import '../../features/traveler/presentation/destination/destinations_screen.dart';
import '../../features/traveler/presentation/qr/qr_screen.dart';
import '../../features/traveler/presentation/trips/view/trips_screen.dart';
import '../entities/booking_entity.dart';
import '../entities/trip_entity.dart';

class AppRouter {
  AppRouter._();

  static const String driverHome = '/driver-home';
  static const String otpScreen = '/otp';
  static const String phoneInput = '/phone-input';
  static const String roleSelection = '/role-selection';
  static const String ratingScreen = '/rating';
  static const String destinations = '/destinations';
  static const String trips = '/trips';
  static const String booking = '/booking';
  static const String qr = '/qr';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
         case roleSelection:
        return _buildRoute(const RoleSelectionScreen());
      case destinations:
        return _buildRoute(const DestinationsScreen());
      case driverHome:
        return _buildRoute(const DriverHomeScreen());
      case otpScreen:
        final phone = settings.arguments as String;
        return _buildRoute(OtpScreen(phoneNumber: phone));
      case phoneInput:
        return _buildRoute(const PhoneInputScreen());
      case ratingScreen:
        final args = settings.arguments as Map<String, String>;
        return _buildRoute(
          RatingScreen(
            tripId: args['tripId']!,
            driverName: args['driverName']!,
          ),
        );
      case trips:
        final destinationId = settings.arguments as String;
        return _buildRoute(TripsScreen(destinationId: destinationId));

      case booking:
        final trip = settings.arguments as TripEntity;
        return _buildRoute(
          BookingScreen(trip: trip),
        );

      case qr:
        final booking = settings.arguments as BookingEntity;
        return _buildRoute(
          QrScreen(booking: booking,),
        );

      default:
        return _buildRoute(const RoleSelectionScreen());
    }
  }

  static MaterialPageRoute _buildRoute(Widget screen) {
    return MaterialPageRoute(builder: (_) => screen);
  }
}
