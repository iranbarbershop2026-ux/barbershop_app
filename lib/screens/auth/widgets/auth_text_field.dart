import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

// ── Auth Text Field ───────────────────────────────────────────────────────────
// Reusable input field for auth screens.
// Inherits all styling from AppTheme.inputDecorationTheme — no local overrides.
//
// To adjust global field style (fill, border, focus ring): edit AppTheme.
// To adjust per-field behaviour: use the params below.

class AuthTextField extends StatelessWidget {
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;

  /// Optional suffix widget — e.g. a visibility-toggle icon button.
  final Widget? suffix;

  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  const AuthTextField({
    super.key,
    required this.hint,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      // Design only — no controller wired up yet
      style: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 14,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(prefixIcon, color: AppColors.textHint, size: 19),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffix,
      ),
    );
  }
}
