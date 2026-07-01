import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'intro/intro_screen.dart';

// ── Splash Screen ─────────────────────────────────────────────────────────────
// Entry animation before the onboarding flow.
//
// ── Responsive strategy (per flutter-build-responsive-layout skill) ───────────
// All sizing is driven by LayoutBuilder constraints — never raw MediaQuery width.
// Four breakpoints keep proportions harmonious at every window size:
//
//   small   < 360 px   — compact phones
//   mobile  360–600    — standard phones  ← default
//   tablet  600–1024   — tablets / large phones
//   wide    ≥ 1024     — desktop / landscape tablet
//
// On wide screens the content column is constrained to maxWidth=520 and centered
// so elements never stretch across the full window.
//
// ── Animation ─────────────────────────────────────────────────────────────────
//   _rotationAnim : 0 → 360° (logo circle spin, first 65% of timeline)
//   _scaleAnim    : 0.78 → 1.0 (logo pop-in, first 50%)
//   _fadeAnim     : 0.0 → 1.0 (all content, first 30%)
//   Duration: 1600ms total → navigate after 2600ms

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // One full 360° spin — smooth ease-in-out
    _rotationAnim = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeInOut),
      ),
    );

    // Fade all content in fast — done by 30%
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.30, curve: Curves.easeOut),
      ),
    );

    // Logo pops in: 0.78 → 1.0
    _scaleAnim = Tween<double>(begin: 0.78, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.50, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
    Future.delayed(const Duration(milliseconds: 2600), _navigateToIntro);
  }

  void _navigateToIntro() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const IntroScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // ── Breakpoints ─────────────────────────────────────────────────────
          final w = constraints.maxWidth;
          final isWide   = w >= 1024;
          final isTablet = w >= 600;
          final isSmall  = w < 360;

          // ── Size tokens — all proportionally matched per breakpoint ─────────
          // Logo circle diameter
          final double logoSize = isWide   ? 180.0
              : isTablet ? 150.0
              : isSmall  ?  80.0
              :             110.0;

          // Icon inside logo circle (always 46% of circle)
          final double iconSize = logoSize * 0.46;

          // Title "Barber Shop"
          final double titleSize = isWide   ? 38.0
              : isTablet ? 30.0
              : isSmall  ? 20.0
              :             25.0;

          // Subtitle "آرایشگاه آنلاین"
          final double subSize = isWide   ? 17.0
              : isTablet ? 15.0
              : isSmall  ? 11.0
              :             13.0;

          // Letter spacing scales with title size to stay proportional
          final double letterSpacing = isWide   ? 14.0
              : isTablet ? 11.0
              : isSmall  ?  5.0
              :              8.0;

          // Gap between logo and title
          final double logoTitleGap = isWide   ? 52.0
              : isTablet ? 40.0
              : isSmall  ? 20.0
              :             28.0;

          // Gap between title and subtitle
          final double titleSubGap = isWide   ? 14.0
              : isTablet ? 12.0
              :              8.0;

          // ── Content column — constrained on wide screens ────────────────────
          final content = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Animated logo circle ────────────────────────────────────────
              ScaleTransition(
                scale: _scaleAnim,
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _rotationAnim,
                    builder: (_, child) => Transform.rotate(
                      angle: _rotationAnim.value,
                      child: child,
                    ),
                    child: _LogoCircle(size: logoSize, iconSize: iconSize),
                  ),
                ),
              ),

              SizedBox(height: logoTitleGap),

              // ── Brand name ──────────────────────────────────────────────────
              Text(
                'Barber Shop',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: titleSize,
                  fontWeight: FontWeight.w800,
                  color: AppColors.gold,
                  letterSpacing: letterSpacing,
                  height: 1.0,
                ),
              ),

              SizedBox(height: titleSubGap),

              // ── Persian tagline ─────────────────────────────────────────────
              Text(
                'آرایشگاه آنلاین',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: subSize,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textHint,
                  letterSpacing: 1.5,
                  height: 1.4,
                ),
              ),
            ],
          );

          return Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              // On wide screens: cap width so content never spreads unnaturally
              child: isWide || isTablet
                  ? ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: content,
                    )
                  : content,
            ),
          );
        },
      ),
    );
  }
}

// ── Logo Circle ───────────────────────────────────────────────────────────────
// The animated rotating circle with scissors icon inside.
// RepaintBoundary is on the parent (AnimatedBuilder child) for paint isolation.

class _LogoCircle extends StatelessWidget {
  final double size;
  final double iconSize;

  const _LogoCircle({required this.size, required this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFF252525), Color(0xFF141414)],
          center: Alignment(-0.3, -0.3),
          radius: 1.1,
        ),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.12),
            blurRadius: 24,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _ScissorsPainter(color: AppColors.gold, size: iconSize),
      ),
    );
  }
}

// ── Scissors Painter ──────────────────────────────────────────────────────────
// All coordinates are relative to [size] so the icon scales correctly at any
// logo diameter without changes to this painter.

class _ScissorsPainter extends CustomPainter {
  final Color color;
  final double size;

  const _ScissorsPainter({required this.color, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final cx = canvasSize.width / 2;
    final cy = canvasSize.height / 2;
    final r  = size / 2;

    // Stroke width scales with icon size for visual consistency
    final strokeW = (size * 0.042).clamp(1.8, 3.0);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Center pivot dot — scales with icon
    canvas.drawCircle(Offset(cx, cy), (size * 0.055).clamp(2.0, 4.0), dotPaint);

    // Blade 1: top-left → bottom-right
    canvas.drawLine(
      Offset(cx - r * 0.82, cy - r * 0.82),
      Offset(cx + r * 0.88, cy + r * 0.72),
      linePaint,
    );

    // Blade 2: bottom-left → top-right
    canvas.drawLine(
      Offset(cx - r * 0.82, cy + r * 0.82),
      Offset(cx + r * 0.88, cy - r * 0.72),
      linePaint,
    );

    // Handle rings
    final ringR = (r * 0.32).clamp(6.0, 22.0);
    canvas.drawCircle(Offset(cx - r * 0.96, cy - r * 0.98), ringR, linePaint);
    canvas.drawCircle(Offset(cx - r * 0.96, cy + r * 0.98), ringR, linePaint);
  }

  @override
  bool shouldRepaint(covariant _ScissorsPainter old) =>
      old.color != color || old.size != size;
}
