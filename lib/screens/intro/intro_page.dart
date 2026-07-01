import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'intro_page_data.dart';
import 'widgets/intro_illustration.dart';

// ── Intro Page ────────────────────────────────────────────────────────────────
// A single onboarding slide — fully responsive across every device:
//   old iPhones (320px) · S5 · S24 Ultra · iPhone X/15 Pro Max
//   Z Fold (closed 344px / open 768px) · iPad Air · iPad Pro 12.9"
//   Nest Hub (1024x600) · ultra-wide desktop (1440px+)
//
// ── Responsive strategy ───────────────────────────────────────────────────────
//   1. LayoutBuilder supplies constraints — width AND height both drive sizing.
//   2. Illustration: min(width-based, height-capped) so landscape/short screens
//      never overflow.
//   3. Font sizes: fluid scaling with clamp on tablet/wide (not fixed px).
//   4. Gaps: proportional to height with hard min/max clamps.
//   5. Text block constrained to maxW — never stretches on ultra-wide.
//
// ── Quick tuning guide ────────────────────────────────────────────────────────
//   • Illustration size  → _ilFraction* constants
//   • Font sizes         → _title* / _sub* constants
//   • Gap proportions    → topGap / midGap / titleGap expressions
//   • Max text width     → _maxTextW* constants

class IntroPage extends StatelessWidget {
  final IntroPageData data;
  final BoxConstraints constraints;

  /// Fractional slide offset — Offset(-0.10, 0) → Offset.zero.
  final Animation<Offset> textSlide;

  /// Opacity — 0.0 → 1.0. Synchronized with [textSlide].
  final Animation<double> textFade;

  const IntroPage({
    super.key,
    required this.data,
    required this.constraints,
    required this.textSlide,
    required this.textFade,
  });

  // ── Illustration fraction of screen width (per breakpoint) ─────────────────
  // These drive the width-side of the illustration clamp.
  static const double _ilFractionWide   = 0.38;
  static const double _ilFractionTablet = 0.44;
  static const double _ilFractionMobile = 0.64;
  static const double _ilFractionSmall  = 0.62;

  // Illustration max height-fraction — prevents overflow on short/landscape screens.
  static const double _ilHeightFraction = 0.38;

  // Max text block widths — text never spreads too wide on large screens.
  static const double _maxTextWide   = 780.0;
  static const double _maxTextTablet = 540.0;

  // Bottom bar height — must match the SizedBox in IntroScreen._BottomBar.
  static const double bottomBarHeight       = 78.0;
  static const double bottomBarHeightTablet = 92.0;

  @override
  Widget build(BuildContext context) {
    final w = constraints.maxWidth;
    final h = constraints.maxHeight;

    // ── Breakpoints ───────────────────────────────────────────────────────────
    // Based on width only — height is used for sizing, not categorization.
    final isWide   = w >= 1024; // iPad Pro landscape, desktop, Nest Hub wide
    final isTablet = w >= 600;  // iPad Air/Pro portrait, Z Fold open, large Android
    final isSmall  = w < 360;   // Z Fold closed, very old phones

    // ── Illustration size ─────────────────────────────────────────────────────
    // Width-based: fills a comfortable fraction of the screen width.
    final double ilByWidth = isWide
        ? w * _ilFractionWide
        : isTablet
            ? w * _ilFractionTablet
            : isSmall
                ? w * _ilFractionSmall
                : w * _ilFractionMobile;

    // Height-based ceiling: illustration never exceeds 38% of screen height.
    // This prevents overflow on landscape and short screens (Nest Hub, etc.).
    final double ilByHeight = h * _ilHeightFraction;

    // Height cap: never exceed 38% of screen height (handles landscape / Nest Hub).
    // Clamped first so it's always a valid upper bound for the next clamp.
    final double ilCap  = ilByHeight.clamp(70.0, 420.0);
    // Final size: width-based, but never smaller than 70 or larger than the cap.
    final double ilSize = ilByWidth.clamp(70.0, ilCap);

    // ── Font sizes — fluid on tablet/wide, fixed on small/mobile ─────────────
    // Fluid: scales with w so text feels proportional at any width > 600.
    // Clamped: prevents extremes on ultra-wide or very narrow.
    final double titleSz = isWide
        ? (w * 0.038).clamp(34.0, 52.0)   // iPad Pro: ~39px · Nest Hub: ~39px (fits)
        : isTablet
            ? (w * 0.038).clamp(24.0, 36.0)
            : isSmall
                ? 18.0
                : 21.0;

    final double subSz = isWide
        ? (w * 0.022).clamp(18.0, 26.0)   // iPad Pro: ~23px · Nest Hub: ~23px (fits)
        : isTablet
            ? (w * 0.022).clamp(13.0, 19.0)
            : isSmall
                ? 12.0
                : 13.5;

    // ── Horizontal padding and text max-width ─────────────────────────────────
    final double hPad = isWide
        ? (w * 0.08).clamp(60.0, 120.0)
        : isTablet
            ? 48.0
            : 24.0;

    final double maxTextW = isWide
        ? _maxTextWide
        : isTablet
            ? _maxTextTablet
            : double.infinity;

    // ── Gaps between content elements ─────────────────────────────────────────
    // midGap  : illustration → title   (main breathing room)
    // titleGap: title → subtitle       (tighter — they're related)
    final double midGap   = (h * (isWide ? 0.055 : 0.052)).clamp(28.0, 72.0);
    final double titleGap = (h * 0.016).clamp(8.0, 22.0);

    // Bottom bar height (the Positioned widget in IntroScreen).
    // We pad the Column by this amount at the bottom so the center of the
    // content group aligns with the visual center of the area above the bar.
    final double bottomBar = isTablet ? bottomBarHeightTablet : bottomBarHeight;

    // ── Illustration — static, never animated ─────────────────────────────────
    final illustration = IntroIllustration(imagePath: data.imagePath, size: ilSize);

    // ── Text — slide from left + fade in ──────────────────────────────────────
    Widget animated(Widget child) => SlideTransition(
          position: textSlide,
          child: FadeTransition(opacity: textFade, child: child),
        );

    final title = animated(
      Text(
        data.title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: titleSz,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          height: 1.30,
        ),
      ),
    );

    final subtitle = animated(
      Text(
        data.subtitle,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: subSz,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.80,
        ),
      ),
    );

    // ── Layout — upper-third positioning ─────────────────────────────────────
    // Spacer ratio 2:3 puts content at ~40% from top — between center and top.
    // Adjust flex values to move content:
    //   more top-biased → decrease topFlex or increase bottomFlex
    //   more centered   → make topFlex == bottomFlex
    const int topFlex    = 2;
    const int bottomFlex = 3;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: SizedBox(
        height: h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Upper free space (2 parts)
            const Spacer(flex: topFlex),

            // Illustration
            Center(child: illustration),

            SizedBox(height: midGap),

            // Title
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxTextW),
                child: title,
              ),
            ),

            SizedBox(height: titleGap),

            // Subtitle
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxTextW),
                child: subtitle,
              ),
            ),

            // Lower free space (3 parts) + bottom bar reserve
            const Spacer(flex: bottomFlex),
            SizedBox(height: bottomBar),
          ],
        ),
      ),
    );
  }
}
