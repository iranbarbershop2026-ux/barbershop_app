import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/data/countries.dart';
import '../../../core/theme/app_theme.dart';

// ── Phone Number Field ────────────────────────────────────────────────────────
// Forces LTR internally. Auto-formats digits as: XXX XXX XXXX (Iranian style).
// The formatter inserts spaces after the 3rd and 6th digit automatically.
// The controller's raw text (with spaces) is passed up — callers should strip
// spaces before composing the final number for display/submission.

class PhoneNumberField extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<Country>? onCountryChanged;

  const PhoneNumberField({super.key, this.controller, this.onCountryChanged});

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  Country _selectedCountry = kCountries.first;

  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();

  final GlobalKey _countryButtonKey = GlobalKey();

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  Future<void> _pickCountry() async {
    final buttonBox =
        _countryButtonKey.currentContext!.findRenderObject() as RenderBox;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final topLeft = buttonBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final bottomRight = buttonBox.localToGlobal(
      buttonBox.size.bottomRight(Offset.zero),
      ancestor: overlayBox,
    );

    final position = RelativeRect.fromLTRB(
      topLeft.dx,
      bottomRight.dy + 6,
      overlayBox.size.width - bottomRight.dx,
      0,
    );

    final picked = await showMenu<Country>(
      context: context,
      position: position,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      constraints: const BoxConstraints(maxHeight: 260, minWidth: 210),
      items: kCountries
          .map((country) => PopupMenuItem<Country>(
                value: country,
                height: 42,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      Text(country.flag, style: const TextStyle(fontSize: 17)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          country.nameFa,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+${country.dialCode}',
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );

    if (picked != null) {
      setState(() => _selectedCountry = picked);
      widget.onCountryChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        textAlignVertical: TextAlignVertical.center,
        // Auto-format: insert spaces after 3rd and 6th digit
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _PhoneFormatter(),
        ],
        style: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: '912 123 4567',
          hintTextDirection: TextDirection.ltr,
          hintStyle: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 13,
            fontWeight: FontWeight.w300,
            color: AppColors.textHint.withOpacity(0.55),
          ),
          prefixIcon: _CountryCodeButton(
            key: _countryButtonKey,
            country: _selectedCountry,
            onTap: _pickCountry,
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      ),
    );
  }
}

// ── Phone formatter ────────────────────────────────────────────────────────────
// Formats up to 10 digits as:  XXX XXX XXXX
// (space after digit 3, space after digit 6)

class _PhoneFormatter extends TextInputFormatter {
  static const _maxFormatted = 10; // ≤10 digits → format with spaces
  static const _maxAllowed = 15; // hard cap (ITU-T E.164)

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Hard cap at 15
    final capped =
        digits.length > _maxAllowed ? digits.substring(0, _maxAllowed) : digits;

    String formatted;
    if (capped.length <= _maxFormatted) {
      // ≤10 digits → XXX XXX XXXX
      final buffer = StringBuffer();
      for (int i = 0; i < capped.length; i++) {
        if (i == 3 || i == 6) buffer.write(' ');
        buffer.write(capped[i]);
      }
      formatted = buffer.toString();
    } else {
      // >10 digits → no spaces, raw digits so user sees something is off
      formatted = capped;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ── Country code chip ─────────────────────────────────────────────────────────

class _CountryCodeButton extends StatelessWidget {
  final Country country;
  final VoidCallback onTap;

  const _CountryCodeButton({
    super.key,
    required this.country,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(country.flag, style: const TextStyle(fontSize: 17)),
            const SizedBox(width: 6),
            Text(
              '+${country.dialCode}',
              style: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppColors.textHint,
            ),
            const SizedBox(width: 12),
            Container(width: 1, height: 20, color: AppColors.border),
          ],
        ),
      ),
    );
  }
}
