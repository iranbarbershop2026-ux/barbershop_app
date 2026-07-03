import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';

// ── OTP Code Field ────────────────────────────────────────────────────────────
// Row of single-digit boxes for entering a verification code.
// Auto-advances focus forward on input, backward on backspace.
//
// Purely presentational + local interaction — does not validate, submit, or
// know anything about the real code. Field styling (fill/border/focus ring)
// comes from AppTheme.inputDecorationTheme, same as AuthTextField.

class OtpCodeField extends StatefulWidget {
  final int length;

  const OtpCodeField({super.key, this.length = 5});

  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    final isLast = index == widget.length - 1;
    if (value.isNotEmpty && !isLast) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.length,
        (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: _DigitBox(
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            onChanged: (value) => _onDigitChanged(i, value),
          ),
        ),
      ),
    );
  }
}

// ── Single digit box ──────────────────────────────────────────────────────────

class _DigitBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _DigitBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 54,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        // Design only — no controller value read/submitted anywhere yet
        style: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        decoration: const InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
