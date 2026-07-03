import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'auth_text_field.dart';
import 'primary_button.dart';

// ── Barber Login Tab ──────────────────────────────────────────────────────────
// UI-only form for barbershop login.
// No API calls, no validation logic — design phase only.
//
// Fields  : نام کاربری · رمز عبور (with visibility toggle)
// Extras  : مرا به خاطر بسپار checkbox · فراموشی رمز عبور link · ورود button
//           · register link

class BarberLoginTab extends StatefulWidget {
  const BarberLoginTab({super.key});

  @override
  State<BarberLoginTab> createState() => _BarberLoginTabState();
}

class _BarberLoginTabState extends State<BarberLoginTab> {
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Username ────────────────────────────────────────────────────────
        const AuthTextField(
          hint: 'نام کاربری',
          prefixIcon: Icons.person_outline_rounded,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
        ),

        const SizedBox(height: 14),

        // ── Password ────────────────────────────────────────────────────────
        AuthTextField(
          hint: 'رمز عبور',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          suffix: _VisibilityToggle(
            obscure: _obscurePassword,
            onToggle: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),

        const SizedBox(height: 18),

        // ── Remember me · Forgot password ────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _RememberMeRow(
                value: _rememberMe,
                onChanged: (v) => setState(() => _rememberMe = v ?? false),
              ),
            ),
            _ForgotPasswordLink(
              onTap: () {
                // TODO: navigate to ForgotPasswordScreen once it exists
              },
            ),
          ],
        ),

        const SizedBox(height: 32),

        // ── Login button ────────────────────────────────────────────────────
        PrimaryButton(
          label: 'ورود',
          onPressed: () {
            // TODO: wire to real login request once backend is ready
          },
        ),

        const SizedBox(height: 22),

        // ── Register link ────────────────────────────────────────────────────
        const _RegisterLink(),

        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Visibility Toggle ─────────────────────────────────────────────────────────

class _VisibilityToggle extends StatelessWidget {
  final bool obscure;
  final VoidCallback onToggle;

  const _VisibilityToggle({required this.obscure, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            key: ValueKey(obscure),
            color: AppColors.textHint,
            size: 19,
          ),
        ),
      ),
    );
  }
}

// ── Remember Me Row ───────────────────────────────────────────────────────────

class _RememberMeRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _RememberMeRow({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.gold,
              checkColor: AppColors.bg,
              side: const BorderSide(color: AppColors.textHint, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'مرا به خاطر بسپار',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Forgot Password Link ──────────────────────────────────────────────────────

class _ForgotPasswordLink extends StatelessWidget {
  final VoidCallback onTap;

  const _ForgotPasswordLink({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: const Text(
        'فراموشی رمز عبور؟',
        style: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: AppColors.gold,
        ),
      ),
    );
  }
}

// ── Register Link ─────────────────────────────────────────────────────────────

class _RegisterLink extends StatelessWidget {
  const _RegisterLink();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'حساب کاربری ندارید؟  ',
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () {
            // TODO: navigate to RegisterScreen
          },
          child: const Text(
            'ثبت‌نام کنید',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
            ),
          ),
        ),
      ],
    );
  }
}