import 'package:etla3_ya_osta/features/driver/presentation/view/driver_home_screen.dart';
import 'package:etla3_ya_osta/features/Auth/presentation/screens/otp_screen.dart';
import 'package:etla3_ya_osta/features/Auth/presentation/screens/phone_input_screen.dart';
import 'package:etla3_ya_osta/features/Auth/presentation/screens/rating_screen.dart';
import 'package:etla3_ya_osta/features/Auth/presentation/screens/role_selection_screen.dart';
import 'package:etla3_ya_osta/features/traveler/presentation/directions/view/live_directions_screen.dart';
import 'package:etla3_ya_osta/features/driver/presentation/view/passenger_loading_screen.dart';
import 'package:etla3_ya_osta/features/driver/presentation/view/trip_in_progress_screen.dart';
import 'package:etla3_ya_osta/features/driver/presentation/view/trip_summary_screen.dart';
import 'package:etla3_ya_osta/features/wallet/presentation/view/pages/wallet_page.dart';
import 'package:etla3_ya_osta/features/wallet/presentation/view/pages/transaction_page.dart';
import 'package:etla3_ya_osta/features/payment/presentation/pages/payment_page.dart';
import 'package:etla3_ya_osta/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:etla3_ya_osta/features/driver/presentation/view/driver_wallet_page.dart';
import 'package:etla3_ya_osta/features/notifications/presentation/pages/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/traveler/presentation/booking/view/booking_screen.dart';
import '../../features/traveler/presentation/booking/cubit/booking_cubit.dart';
import '../../features/traveler/presentation/destination/view/destinations_screen.dart';
import '../../features/traveler/presentation/qr/qr_screen.dart';
import '../../features/traveler/presentation/trips/view/trips_screen.dart';
import '../../core/entities/booking_entity.dart';
import '../../core/entities/trip_entity.dart';
import '../di/injection.dart';

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
  static const String liveDirections = '/live-directions';
  static const String passengerLoading = '/passenger-loading';
  static const String tripInProgress = '/trip-in-progress';
  static const String tripSummary = '/trip-summary';
  static const String wallet = '/wallet';
  static const String transactions = '/transactions';
  static const String driverWallet = '/driver-wallet';
  static const String payment = '/payment';
  static const String notifications = '/notifications';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case roleSelection:
        return _buildRoute(const RoleSelectionScreen());
      case destinations:
        return _buildRoute(const DestinationsScreen());
      case driverHome:
        return _buildRoute(const DriverHomeScreen());
      case passengerLoading:
        return _buildRoute(const PassengerLoadingScreen());
      case tripInProgress:
        return _buildRoute(const TripInProgressScreen());
      case tripSummary:
        return _buildRoute(const TripSummaryScreen());
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
            driverId: args['driverId']!,
            travelerId: args['travelerId']!,
          ),
        );
      case trips:
        final destinationId = settings.arguments as String;
        return _buildRoute(TripsScreen(destinationId: destinationId));

      case booking:
        final trip = settings.arguments as TripEntity;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<BookingCubit>(),
            child: BookingScreen(trip: trip),
          ),
        );

      case qr:
        final booking = settings.arguments as BookingEntity;
        return _buildRoute(QrScreen(booking: booking));

      case liveDirections:
        return _buildRoute(LiveDirectionsScreen());

      case wallet:
        return _buildRoute(const WalletPage());

      case transactions:
        return _buildRoute(const TransactionsPage());

      case driverWallet:
        return _buildRoute(const DriverWalletPage());

      case payment:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<PaymentCubit>()),
              BlocProvider(create: (_) => sl<BookingCubit>()),
            ],
            child: PaymentPage(
              bookingId: args['bookingId'] as String,
              amount: args['amount'] as double,
              travelerName: args['travelerName'] as String,
              travelerPhone: args['travelerPhone'] as String,
              trip: args['trip'] as TripEntity?,
              travelerId: args['travelerId'] as String?,
              seatNumber: args['seatNumber'] as int?,
              driverId: args['driverId'] as String?,
            ),
          ),
        );

      case notifications:
        return _buildRoute(const NotificationsPage());

      default:
        return _buildRoute(const RoleSelectionScreen());
    }
  }

  static MaterialPageRoute _buildRoute(Widget screen) {
    return MaterialPageRoute(builder: (_) => screen);
  }
}