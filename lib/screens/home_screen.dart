import 'package:flutter/material.dart';

// google_fonts package removed to avoid missing package import error.
// If you add google_fonts to pubspec.yaml, you can restore the import
// and use GoogleFonts.vazirmatn as before.
import '../core/theme/app_theme.dart';

/// Placeholder — will be replaced with full home screen in next phase.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'BARBER',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.gold,
            letterSpacing: 6,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: const Center(
        child: Text(
          'خوش آمدید',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
