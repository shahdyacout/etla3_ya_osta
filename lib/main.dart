
import 'package:flutter/material.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const MasarApp());
}

class MasarApp extends StatelessWidget {
  const MasarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masar',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}