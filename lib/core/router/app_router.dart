
import 'package:etla3_ya_osta/features/Auth/presentation/screens/otp_screen.dart';
import 'package:etla3_ya_osta/features/Auth/presentation/screens/phone_input_screen.dart';
import 'package:etla3_ya_osta/features/Auth/presentation/screens/role_selection_screen.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/traveler_home_screen.dart';
import '../../features/auth/presentation/screens/driver_home_screen.dart';

class AppRouter {
  AppRouter._();
  static const String splash        = '/';
  static const String travelerHome  = '/traveler-home';
  static const String driverHome    = '/driver-home';
  static const String otpScreen = '/otp';
  static const String phoneInput = '/phone-input';
  static const String roleSelection = '/role-selection';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen());

      case travelerHome:
        return _buildRoute(const TravelerHomeScreen());

      case driverHome:
        return _buildRoute(const DriverHomeScreen());
      case otpScreen:
        final phone = settings.arguments as String;
       return _buildRoute(OtpScreen(phoneNumber: phone));
      case phoneInput:
      return _buildRoute(const PhoneInputScreen());
      case roleSelection:
      return _buildRoute(const RoleSelectionScreen());
      default:
        return _buildRoute(const SplashScreen());
    }
  }
  static MaterialPageRoute _buildRoute(Widget screen) {
    return MaterialPageRoute(builder: (_) => screen);
  }
}