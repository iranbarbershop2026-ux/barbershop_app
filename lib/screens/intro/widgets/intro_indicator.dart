import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

// ── Slide Indicator ───────────────────────────────────────────────────────────
// Animated pill-style dots. Active dot expands to a wider pill in gold;
// inactive dots are small circles in muted color.

class IntroIndicator extends StatelessWidget {
  final int total;
  final int current;

  const IntroIndicator({
    super.key,
    required this.total,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      // RTL: dot index 0 is leftmost physically, but in Persian the first
      // slide should light up the RIGHTMOST dot. Flip by mirroring index.
      children: List.generate(
        total,
        (i) => _Dot(isActive: i == (total - 1 - current)),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool isActive;

  const _Dot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 22.0 : 7.0,
      height: 7.0,
      decoration: BoxDecoration(
        color: isActive ? AppColors.gold : AppColors.textHint,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
