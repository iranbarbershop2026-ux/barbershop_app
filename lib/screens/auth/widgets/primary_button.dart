import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

// ── Primary Button ────────────────────────────────────────────────────────────
// Shared solid-gold CTA used across auth screens (ورود · دریافت کد · تایید و
// ورود ...). Press feedback: scales down slightly + dims to `goldDim`.
//
// Extracted from BarberLoginTab's old private `_LoginButton` so every auth
// action shares one implementation — change it once, it updates everywhere.

class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        // AnimatedContainer handles color transition on press — no external shadow
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 54,
          decoration: BoxDecoration(
            color: _pressed ? AppColors.goldDim : AppColors.gold,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                // Text stays readable against both gold and goldDim
                color: AppColors.bg,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
