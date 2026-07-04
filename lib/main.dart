import 'package:barbershop_app/screens/customer_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemOverlay);
  runApp(const BarberApp());
}

class BarberApp extends StatelessWidget {
  const BarberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BarberShop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const CustomerHomeScreen(),
    );
  }
}
