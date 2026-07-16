import 'dart:async';

import 'package:barbershop_app/screens/customer_home_screen.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'widgets/primary_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const _codeLength = 5;
  static const _resendSeconds = 105;

  // Fixed-length list: null = empty slot, String = filled digit.
  // This way replacing a digit never shifts the others.
  late final List<String?> _slots = List.filled(_codeLength, null);

  int _secondsLeft = _resendSeconds;
  Timer? _timer;

  // Which box has the cursor. -1 = follow natural fill position.
  int _cursorIndex = -1;

  // Error banner shown when backend rejects the code (simulated for now).
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  // Filled digit count (for "is complete" checks).
  int get _filledCount => _slots.where((s) => s != null).length;

  // The active (cursor) box index.
  // If _cursorIndex is set explicitly, use it.
  // Otherwise: first empty slot, or last slot when all filled.
  int get _activeIndex {
    if (_cursorIndex >= 0) return _cursorIndex;
    final first = _slots.indexWhere((s) => s == null);
    return first == -1 ? _codeLength - 1 : first;
  }

  // ── Interactions ──────────────────────────────────────────────────────────

  void _onBoxTap(int index) {
    // Only allow tapping on filled slots to reposition cursor
    if (_slots[index] != null) {
      setState(() => _cursorIndex = index);
    }
  }

  void _onDigit(String digit) {
    final target = _activeIndex;
    setState(() {
      _slots[target] = digit;
      _errorMessage = null;
      // Advance cursor to next empty slot after target, or release override
      final next = _slots.indexWhere((s) => s == null, target + 1);
      _cursorIndex = next == -1 ? -1 : next;
    });
  }

  void _onClear() {
    final target = _activeIndex;
    if (_slots[target] != null) {
      // Clear this slot, keep cursor here so next digit replaces it
      setState(() {
        _slots[target] = null;
        _cursorIndex = target;
        _errorMessage = null;
      });
    } else if (target > 0) {
      // Already empty — clear the previous filled slot
      final prev = target - 1;
      setState(() {
        _slots[prev] = null;
        _cursorIndex = prev;
        _errorMessage = null;
      });
    }
  }

  void _onAutoFill() {
    // TODO: wire to real SMS autofill
  }

  void _onResend() {
    // TODO: wire to real resend OTP request
    setState(() {
      _secondsLeft = _resendSeconds;
      _errorMessage = null;
    });
    _startTimer();
  }

  void _onVerify() {
    if (_filledCount < _codeLength) return;
    // TODO: wire to real OTP verification API.
    // For now, navigate directly to HomeScreen (design phase).
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => const CustomerHomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 380),
      ),
      (route) => false, // clear the entire auth stack
    );
  }

  String get _timerLabel {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _goBack(BuildContext context) => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final isComplete = _filledCount == _codeLength;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _BackRow(onTap: () => _goBack(context)),
                  ),
                ),
                const SizedBox(height: 26),
                const Text(
                  'کد تایید ۵ رقمی',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                _SentMessage(phoneNumber: widget.phoneNumber),
                const SizedBox(height: 30),
                _OtpDigitsRow(
                  slots: _slots,
                  activeIndex: _activeIndex,
                  onBoxTap: _onBoxTap,
                ),
                const SizedBox(height: 14),
                // Error banner — only visible when _errorMessage is set
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _errorMessage != null
                      ? _ErrorBanner(
                          key: const ValueKey('err'),
                          message: _errorMessage!,
                        )
                      : const SizedBox(key: ValueKey('no-err'), height: 8),
                ),
                const SizedBox(height: 8),
                _ResendCountdown(
                  secondsLeft: _secondsLeft,
                  label: _timerLabel,
                  onResend: _onResend,
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: _Keypad(
                    onDigit: _onDigit,
                    onClear: _onClear,
                    onAutoFill: _onAutoFill,
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedOpacity(
                  opacity: isComplete ? 1.0 : 0.45,
                  duration: const Duration(milliseconds: 200),
                  child: PrimaryButton(
                    label: 'تایید و ورود به اپلیکیشن',
                    onPressed: isComplete ? _onVerify : null,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Back row ──────────────────────────────────────────────────────────────────

class _BackRow extends StatelessWidget {
  final VoidCallback onTap;
  const _BackRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chevron_left_rounded,
                size: 20, color: AppColors.textSecondary),
            SizedBox(width: 2),
            Text(
              'تغییر شماره موبایل',
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sent-to message ───────────────────────────────────────────────────────────

class _SentMessage extends StatelessWidget {
  final String phoneNumber;
  const _SentMessage({required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.right,
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.7,
        ),
        children: [
          const TextSpan(text: 'پیامک حاوی کد به شماره '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                phoneNumber,
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
          const TextSpan(text: ' ارسال شد.'),
        ],
      ),
    );
  }
}

// ── OTP digit boxes ───────────────────────────────────────────────────────────

class _OtpDigitsRow extends StatelessWidget {
  final List<String?> slots;
  final int activeIndex;
  final ValueChanged<int> onBoxTap;

  const _OtpDigitsRow({
    required this.slots,
    required this.activeIndex,
    required this.onBoxTap,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(slots.length, (i) {
          return GestureDetector(
            onTap: () => onBoxTap(i),
            behavior: HitTestBehavior.opaque,
            child: _OtpBox(
              digit: slots[i] ?? '',
              isActive: i == activeIndex,
            ),
          );
        }),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final String digit;
  final bool isActive;

  const _OtpBox({required this.digit, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 54,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? AppColors.gold : Colors.transparent,
          width: 1.6,
        ),
      ),
      child: digit.isNotEmpty
          ? Text(
              digit,
              style: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            )
          : (isActive ? const _BlinkingCursor() : null),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(width: 2, height: 24, color: AppColors.gold),
    );
  }
}

// ── Error banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE0574B).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFE0574B).withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 16, color: Color(0xFFE0574B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE0574B),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Resend countdown ──────────────────────────────────────────────────────────

class _ResendCountdown extends StatelessWidget {
  final int secondsLeft;
  final String label;
  final VoidCallback onResend;

  const _ResendCountdown({
    required this.secondsLeft,
    required this.label,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    if (secondsLeft <= 0) {
      return Center(
        child: GestureDetector(
          onTap: onResend,
          behavior: HitTestBehavior.opaque,
          child: const Text(
            'ارسال مجدد کد',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
            ),
          ),
        ),
      );
    }

    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
          children: [
            const TextSpan(text: 'ارسال مجدد کد پس از '),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom keypad ─────────────────────────────────────────────────────────────

class _Keypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onClear;
  final VoidCallback onAutoFill;

  const _Keypad({
    required this.onDigit,
    required this.onClear,
    required this.onAutoFill,
  });

  static const _dangerColor = Color(0xFFE0574B);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _digitRow(const ['1', '2', '3']),
        _digitRow(const ['4', '5', '6']),
        _digitRow(const ['7', '8', '9']),
        Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              Expanded(
                child: _KeypadKey(
                  onTap: onClear,
                  child: const Text(
                    'پاک',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _dangerColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _KeypadKey(
                  onTap: () => onDigit('0'),
                  child: const Text('0', style: _digitStyle),
                ),
              ),
              Expanded(
                child: _KeypadKey(
                  onTap: onAutoFill,
                  child: const Text(
                    'خودکار',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _digitRow(List<String> digits) {
    return Row(
      children: digits
          .map((d) => Expanded(
                child: _KeypadKey(
                  onTap: () => onDigit(d),
                  child: Text(d, style: _digitStyle),
                ),
              ))
          .toList(),
    );
  }

  static const _digitStyle = TextStyle(
    fontFamily: 'Vazirmatn',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}

class _KeypadKey extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _KeypadKey({required this.child, required this.onTap});

  @override
  State<_KeypadKey> createState() => _KeypadKeyState();
}

class _KeypadKeyState extends State<_KeypadKey> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _pressed
                ? AppColors.gold.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _pressed
                  ? AppColors.gold.withValues(alpha: 0.55)
                  : Colors.transparent,
              width: 1.4,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
