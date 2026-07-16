import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

// ── Intro Illustration ────────────────────────────────────────────────────────
// Renders an asset image centered inside a styled dark circle.
//
// Layout:
//   • Dark filled circle (#141414) — the background canvas
//   • Thin gold ring border (opacity 0.32) — subtle brand accent
//   • Soft gold ambient glow (BoxShadow) — depth without distraction
//   • Image.asset — padded to ~20% inset so it breathes inside the circle
//
// To adjust image padding: change [_imagePaddingFraction]
// To adjust ring opacity: change the border color opacity below

class IntroIllustration extends StatelessWidget {
  final String imagePath;
  final double size;

  // How much breathing room the image gets inside the circle.
  // 0.18 = image occupies ~64% of the circle diameter.
  static const double _imagePaddingFraction = 0.18;

  const IntroIllustration({
    super.key,
    required this.imagePath,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final padding = size * _imagePaddingFraction;

    return RepaintBoundary(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF141414),
          // Thin gold ring
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.32),
            width: 1.2,
          ),
          // Ambient gold glow
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.07),
              blurRadius: 28,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
