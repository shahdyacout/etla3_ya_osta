import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../driver/presentation/cubit/driver_cubit.dart';
import '../../../driver/presentation/view/driver_home_screen.dart' as real;

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DriverCubit>(
      create: (_) => sl<DriverCubit>(),
      child: const real.DriverHomeScreen(),
    );
  }
}
