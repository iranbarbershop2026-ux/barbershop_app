import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../home_screen.dart';
import 'intro_page.dart';
import 'intro_page_data.dart';
import 'widgets/intro_indicator.dart';

// ── Intro Screen ──────────────────────────────────────────────────────────────
// Orchestrates the 3-slide onboarding flow.
//
// ── Animation timeline (per page transition) ─────────────────────────────────
//
//   0 ms  : _next() called → PageView.nextPage() starts (480ms, easeInOutSine)
//  ~240ms : onPageChanged fires (PageView is at its midpoint)
//  ~490ms : slide finishes; text animation begins (240ms + 250ms delay)
//  ~870ms : text fully settled (490ms + 380ms animation)
//
// This creates the "artifact loading slightly after the page" feeling:
//   → slide completes → text gently slides in from the left and fades up.
//
// ── Text animation ───────────────────────────────────────────────────────────
//   Slide : Offset(-0.10, 0) → Offset.zero  (10% of widget width, from left)
//   Fade  : 0.0 → 1.0
//   Curve : easeOutCubic (decelerates smoothly, feels like settling)
//   Duration: 380ms
//
// ── Illustration ─────────────────────────────────────────────────────────────
//   Always fully visible — no animation, no fade, no scale. Clean and instant.
//
// ── First page ───────────────────────────────────────────────────────────────
//   _textCtrl starts at value=1.0 so page 0 has no animation on first render.

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────────────────────
  late final PageController _pageController;

  /// Drives both text animations. Single controller keeps slide + fade in sync.
  late final AnimationController _textCtrl;

  /// Text slides from -10% (left) → 0 horizontally. Fractional offset so it
  /// scales correctly at any screen width.
  late final Animation<Offset> _textSlide;

  /// Text fades from fully invisible → fully visible.
  late final Animation<double> _textFade;

  // ── Page state ────────────────────────────────────────────────────────────────
  int _page = 0;
  // Derived from the data list — adding a page there automatically updates the flow.
  static final int _total = IntroPageData.pages.length;
  static const _pageDuration = Duration(milliseconds: 480);
  static const _textDelay    = Duration(milliseconds: 250);
  static const _textDuration = Duration(milliseconds: 380);

  /// Pages whose text animation has already played at least once.
  /// Page 0 is pre-seeded — it never animates on first render.
  /// Any page added here will show static text on subsequent visits.
  final Set<int> _visitedPages = {0};

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    _textCtrl = AnimationController(
      vsync: this,
      duration: _textDuration,
    );

    // Slide: enter from left — Offset x is fractional (−0.10 = 10% to the left)
    _textSlide = Tween<Offset>(
      begin: const Offset(-0.10, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textCtrl,
      curve: Curves.easeOutCubic,
    ));

    // Fade: 0 → 1 on the same curve for a unified feel
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic),
    );

    // Page 0 has no enter animation — text is immediately at full opacity/position.
    _textCtrl.value = 1.0;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  // ── Page interaction ──────────────────────────────────────────────────────────

  void _onPageChanged(int newPage) {
    setState(() => _page = newPage);

    if (_visitedPages.contains(newPage)) {
      // Page already seen — snap text to fully visible, no animation.
      // Handles: swipe back, swipe forward to a revisited page.
      _textCtrl.value = 1.0;
    } else {
      // First visit — mark as seen and play the slide+fade animation.
      _visitedPages.add(newPage);
      _textCtrl.value = 0.0;
      Future.delayed(_textDelay, () {
        if (mounted) _textCtrl.forward();
      });
    }
  }

  void _next() {
    if (_page < _total - 1) {
      _pageController.nextPage(
        duration: _pageDuration,
        curve: Curves.easeInOutSine, // smooth breath-like page motion
      );
    } else {
      _goHome();
    }
  }

  void _skip() => _goHome();

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.systemOverlay,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final isTablet = w >= 600;
              final isWide = w >= 1024;
              final hPad = isWide
                  ? 52.0
                  : isTablet
                      ? 36.0
                      : 20.0;

              return Stack(
                children: [
                  // ── Page slides (RTL: page 0 = rightmost) ──────────────────
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _total,
                      onPageChanged: _onPageChanged,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (_, i) => IntroPage(
                        data: IntroPageData.pages[i],
                        constraints: constraints,
                        textSlide: _textSlide,
                        textFade: _textFade,
                      ),
                    ),
                  ),

                  // ── Skip button (top-left, hidden on last slide) ────────────
                  Positioned(
                    top: 8,
                    left: 12,
                    child: AnimatedOpacity(
                      opacity: _page < _total - 1 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: IgnorePointer(
                        ignoring: _page >= _total - 1,
                        child: GestureDetector(
                          onTap: _skip,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: isTablet ? 12.0 : 10.5,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'رد کردن',
                                  style: TextStyle(
                                    fontFamily: 'Vazirmatn',
                                    fontSize: isTablet ? 13.0 : 11.5,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.2,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Bottom bar (next button + dot indicator) ────────────────
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _BottomBar(
                      page: _page,
                      total: _total,
                      isTablet: isTablet,
                      hPad: hPad,
                      onNext: _next,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Bottom Bar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int page;
  final int total;
  final bool isTablet;
  final double hPad;
  final VoidCallback onNext;

  const _BottomBar({
    required this.page,
    required this.total,
    required this.isTablet,
    required this.hPad,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = page == total - 1;

    return SizedBox(
      height: isTablet ? IntroPage.bottomBarHeightTablet : IntroPage.bottomBarHeight,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _NextButton(
                label: isLast ? 'شروع کن' : 'بعدی',
                isLast: isLast,
                isTablet: isTablet,
                onTap: onNext,
              ),
              IntroIndicator(total: total, current: page),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Next Button ───────────────────────────────────────────────────────────────

class _NextButton extends StatefulWidget {
  final String label;
  final bool isLast;
  final bool isTablet;
  final VoidCallback onTap;

  const _NextButton({
    required this.label,
    required this.isLast,
    required this.isTablet,
    required this.onTap,
  });

  @override
  State<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<_NextButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isTablet ? 28.0 : 22.0,
            vertical: widget.isTablet ? 14.0 : 11.0,
          ),
          decoration: BoxDecoration(
            color: widget.isLast ? AppColors.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: AppColors.gold, width: 1.5),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: widget.isTablet ? 15.0 : 13.5,
              fontWeight: FontWeight.w600,
              color: widget.isLast ? AppColors.bg : AppColors.gold,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
