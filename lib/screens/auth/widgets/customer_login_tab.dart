import 'package:flutter/material.dart';

import '../../../core/data/countries.dart';
import '../../../core/theme/app_theme.dart';
import '../otp_verification_screen.dart';
import 'phone_number_field.dart';
import 'primary_button.dart';

class CustomerLoginTab extends StatefulWidget {
  /// اگر از بیرون پاس داده بشه، controller عمر طولانی‌تری داره و
  /// با جابجایی بین تب‌ها reset نمیشه.
  final TextEditingController? phoneController;

  const CustomerLoginTab({super.key, this.phoneController});

  @override
  State<CustomerLoginTab> createState() => _CustomerLoginTabState();
}

class _CustomerLoginTabState extends State<CustomerLoginTab> {
  // اگر parent controller نداد، خودمون یکی می‌سازیم
  late final TextEditingController _phoneController =
      widget.phoneController ?? TextEditingController();
  Country _selectedCountry = kCountries.first; // Iran default

  String? _fieldError; // shown under the phone field

  @override
  void initState() {
    super.initState();
    // Clear error as soon as user starts typing
    _phoneController.addListener(() {
      if (_fieldError != null) setState(() => _fieldError = null);
    });
  }

  @override
  void dispose() {
    // فقط اگه خودمون ساختیم dispose کنیم
    if (widget.phoneController == null) _phoneController.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────
  // Iran (+98): 10 digits starting with 09, e.g. 09121234567 or 9121234567.
  // For other countries we only check that the field isn't empty and has
  // at least 7 digits — expand per-country rules when the app goes global.
  String? _validate() {
    final raw = _phoneController.text.trim();

    if (raw.isEmpty) {
      return 'لطفاً شماره موبایل خود را وارد کنید.';
    }

    final digits = raw.replaceAll(RegExp(r'\D'), '');

    if (_selectedCountry.dialCode == '98') {
      // Must be exactly 10 digits starting with 9
      if (digits.length != 10) {
        return 'شماره موبایل وارد شده نامعتبر است.';
      }
      if (!digits.startsWith('9')) {
        return 'شماره موبایل وارد شده نامعتبر است.';
      }
    } else {
      if (digits.length < 7) {
        return 'شماره موبایل وارد شده نامعتبر است.';
      }
    }

    return null; // valid
  }

  void _goToOtpScreen() {
    final error = _validate();
    if (error != null) {
      setState(() => _fieldError = error);
      return;
    }

    // Keep spaces for display on the OTP screen (e.g. "+98 912 345 6789")
    final composedNumber =
        '+${_selectedCountry.dialCode} ${_phoneController.text.trim()}';
    Navigator.push(
      context,
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) =>
            OtpVerificationScreen(phoneNumber: composedNumber),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final enterSlide = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation);

          final exitSlide = Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-0.30, 0.0),
          )
              .chain(CurveTween(curve: Curves.easeInCubic))
              .animate(secondaryAnimation);

          return SlideTransition(
            position: exitSlide,
            child: SlideTransition(position: enterSlide, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 340),
        reverseTransitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PhoneNumberField(
          controller: _phoneController,
          onCountryChanged: (c) {
            setState(() {
              _selectedCountry = c;
              _fieldError = null;
            });
          },
        ),

        // ── Validation error / helper text ────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _fieldError != null
              ? _FieldError(key: const ValueKey('err'), message: _fieldError!)
              : const _HelperText(key: ValueKey('hint')),
        ),

        const SizedBox(height: 56),

        PrimaryButton(label: 'دریافت کد تایید', onPressed: _goToOtpScreen),

        const SizedBox(height: 16),

        const _PrivacyNote(),

        const SizedBox(height: 4),
      ],
    );
  }
}

// ── Helper text (default) ─────────────────────────────────────────────────────

class _HelperText extends StatelessWidget {
  const _HelperText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 8, right: 4, left: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          'کد تایید ۵ رقمی به این شماره پیامک می‌شود',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 11.5,
            fontWeight: FontWeight.w400,
            color: AppColors.textHint,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

// ── Field error (با shake animation) ─────────────────────────────────────────

class _FieldError extends StatefulWidget {
  final String message;
  const _FieldError({super.key, required this.message});

  @override
  State<_FieldError> createState() => _FieldErrorState();
}

class _FieldErrorState extends State<_FieldError>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    // Shake: سریع چپ و راست — مثل تکان دادن سر به معنای "نه"
    _shake = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: -5), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -5, end: 5), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 5, end: -3), weight: 1.5),
      TweenSequenceItem(tween: Tween(begin: -3, end: 0), weight: 1.5),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    // شروع shake بعد از اینکه widget ظاهر شد
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shake,
      builder: (_, child) => Transform.translate(
        offset: Offset(_shake.value, 0),
        child: child,
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, right: 4, left: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(
                Icons.error_outline_rounded,
                size: 13,
                color: Color(0xFFE0574B),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                widget.message,
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFE0574B),
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Privacy note ──────────────────────────────────────────────────────────────

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerRight,
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
