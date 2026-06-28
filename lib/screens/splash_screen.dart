import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

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

    // Fade in fast, done by 30%
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.30, curve: Curves.easeOut),
      ),
    );

    // Scale: grows from 0.78 to 1.0
    _scaleAnim = Tween<double>(begin: 0.78, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.50, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2600), _navigateToHome);
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
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
    // Responsive sizing based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = (screenWidth * 0.285).clamp(96.0, 130.0);
    final iconSize = logoSize * 0.46;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Animated logo ───────────────────────────────
              ScaleTransition(
                scale: _scaleAnim,
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _rotationAnim,
                    builder: (_, child) => Transform.rotate(
                      angle: _rotationAnim.value,
                      child: child,
                    ),
                    child: _LogoCircle(
                      size: logoSize,
                      iconSize: iconSize,
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenWidth * 0.07),

              // ── BARBR wordmark ──────────────────────────────
              Text(
                'Barber Shop',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: screenWidth * 0.072,
                  fontWeight: FontWeight.w800,
                  color: AppColors.gold,
                  letterSpacing: 10,
                ),
              ),

              const SizedBox(height: 10),

              // ── Tagline فارسی ───────────────────────────────
              const Text(
                'آرایشگاه آنلاین',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textHint,
                  letterSpacing: 1.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Logo Circle ──────────────────────────────────────────────────────────────
// RepaintBoundary is set on the parent; this widget itself is const-safe.

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
        // Simple radial gradient — avoids expensive gradients during rotation
        gradient: const RadialGradient(
          colors: [Color(0xFF252525), Color(0xFF141414)],
          center: Alignment(-0.3, -0.3),
          radius: 1.1,
        ),
        // Thin gold border — premium feel
        border: Border.all(
          color: AppColors.gold.withOpacity(0.45),
          width: 1.5,
        ),
        boxShadow: [
          // Outer glow — subtle, not expensive
          BoxShadow(
            color: AppColors.gold.withOpacity(0.12),
            blurRadius: 24,
            spreadRadius: 0,
            offset: Offset.zero,
          ),
          // Depth shadow — ground the circle
          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _ScissorsPainter(
          color: AppColors.gold,
          size: iconSize,
        ),
      ),
    );
  }
}

// ── Scissors Painter ─────────────────────────────────────────────────────────

class _ScissorsPainter extends CustomPainter {
  final Color color;
  final double size;

  const _ScissorsPainter({required this.color, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final cx = canvasSize.width / 2;
    final cy = canvasSize.height / 2;
    final r = size / 2;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Center pivot dot
    canvas.drawCircle(Offset(cx, cy), 3.2, dotPaint);

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
    canvas.drawCircle(
      Offset(cx - r * 0.96, cy - r * 0.98),
      r * 0.32,
      linePaint,
    );
    canvas.drawCircle(
      Offset(cx - r * 0.96, cy + r * 0.98),
      r * 0.32,
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScissorsPainter old) =>
      old.color != color || old.size != size;
}
