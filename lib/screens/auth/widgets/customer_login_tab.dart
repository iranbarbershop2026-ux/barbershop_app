import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'otp_code_field.dart';
import 'phone_number_field.dart';
import 'primary_button.dart';

// ── Customer Login Tab ────────────────────────────────────────────────────────
// UI-only OTP flow for customer login.
// No API calls, no real verification, no real countdown timer — design phase
// only. Every action below is either a TODO or a purely local UI toggle.
//
// Step 1 (idle) : شماره موبایل (با انتخاب‌گر پیش‌شماره‌ی کشور) → دکمه‌ی
//                 «دریافت کد تایید»
// Step 2 (sent) : کد ۵ رقمی → «ویرایش شماره» / «ارسال مجدد کد» → «تایید و ورود»
//
// Switching between steps reuses the exact fade+slide transition already used
// for switching between the barbershop/customer tabs in LoginScreen, so every
// transition in the auth flow feels consistent.

class CustomerLoginTab extends StatefulWidget {
  const CustomerLoginTab({super.key});

  @override
  State<CustomerLoginTab> createState() => _CustomerLoginTabState();
}

class _CustomerLoginTabState extends State<CustomerLoginTab> {
  bool _codeSent = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.03, 0),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: _codeSent
          ? _OtpStep(
              key: const ValueKey('otp'),
              onEditNumber: () => setState(() => _codeSent = false),
            )
          : _PhoneStep(
              key: const ValueKey('phone'),
              onCodeRequested: () => setState(() => _codeSent = true),
            ),
    );
  }
}

// ── Step 1: phone number ──────────────────────────────────────────────────────

class _PhoneStep extends StatelessWidget {
  final VoidCallback onCodeRequested;

  const _PhoneStep({super.key, required this.onCodeRequested});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Phone number ──────────────────────────────────────────────────
        const PhoneNumberField(),

        const SizedBox(height: 10),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'کد تایید ۵ رقمی به این شماره پیامک می‌شود',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              color: AppColors.textHint,
              height: 1.6,
            ),
          ),
        ),

        // Fixed (not flexible) gap: this form area sizes itself from its own
        // content — its ancestors never constrain its height — so an
        // Expanded/Flexible here has no bounded space to grow into and
        // breaks layout entirely. A generous fixed gap approximates the same
        // "push the button down" effect safely.
        const SizedBox(height: 56),

        // TODO: wire to real "send OTP" request once backend is ready
        PrimaryButton(label: 'دریافت کد تایید', onPressed: onCodeRequested),

        const SizedBox(height: 16),

        // Small footer note — subordinate to the caption above, so the two
        // don't compete for attention stacked on top of each other.
        const _PrivacyNote(),

        const SizedBox(height: 4),
      ],
    );
  }
}

// ── Privacy note ───────────────────────────────────────────────────────────────

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 13, color: AppColors.textHint),
          SizedBox(width: 6),
          Text(
            'شماره شما نزد ما محفوظ می‌ماند',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 2: OTP entry ─────────────────────────────────────────────────────────

class _OtpStep extends StatelessWidget {
  final VoidCallback onEditNumber;

  const _OtpStep({super.key, required this.onEditNumber});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SentToRow(onEdit: onEditNumber),

        const SizedBox(height: 22),

        // ── Code digits ──────────────────────────────────────────────────
        const OtpCodeField(),

        const SizedBox(height: 18),

        _ResendRow(
          onResend: () {
            // TODO: wire to real "resend OTP" request + real countdown timer
          },
        ),

        const SizedBox(height: 28),

        // TODO: wire to real "verify OTP" request once backend is ready
        PrimaryButton(
          label: 'تایید و ورود',
          onPressed: () {},
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}

// ── "sent to ... · edit" row ──────────────────────────────────────────────────

class _SentToRow extends StatelessWidget {
  final VoidCallback onEdit;

  const _SentToRow({required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // TODO: interpolate the real phone number the user entered in step 1
        const Flexible(
          child: Text(
            'کد ارسال شده را وارد کنید',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onEdit,
          behavior: HitTestBehavior.opaque,
          child: const Text(
            'ویرایش',
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

// ── Resend row ─────────────────────────────────────────────────────────────────

class _ResendRow extends StatelessWidget {
  final VoidCallback onResend;

  const _ResendRow({required this.onResend});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onResend,
        behavior: HitTestBehavior.opaque,
        child: const Text(
          'ارسال مجدد کد',
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: AppColors.gold,
          ),
        ),
      ),
    );
  }
}
