import 'package:etla3_ya_osta/features/Auth/presentation/cubit/auth_cubit_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/di/service_locator.dart';
import 'features/traveler/presentation/booking/cubit/booking_cubit.dart';
import 'features/traveler/presentation/destination/cubit/destinations_cubit.dart';
import 'features/traveler/presentation/trips/cubit/trips_cubit.dart';
import 'firebase_options.dart';
import 'core/entities/user_role_entity.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'features/Auth/presentation/cubit/auth_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => createAuthCubit()),
        BlocProvider(
          create: (_) => sl<DestinationsCubit>()..loadDestinations(),
        ),
        BlocProvider(create: (_) => sl<TripsCubit>()),
        BlocProvider(create: (_) => sl<BookingCubit>()),
      ],
      child: const MasarApp(),
    ),
  );
}

class MasarApp extends StatelessWidget {
  const MasarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masar',
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final authCubit = context.read<AuthCubit>();
    await authCubit.checkAuth();

    if (!mounted) return;
    final state = authCubit.state;
    if (state.isAuthenticated && state.role != null) {
      final route = state.role == UserRole.traveler
          ? AppRouter.destinations
          : AppRouter.driverHome;
      if (mounted) {
        Navigator.pushReplacementNamed(context, route);
      }
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.roleSelection);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Masar',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
        leadingWidth: 100,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
