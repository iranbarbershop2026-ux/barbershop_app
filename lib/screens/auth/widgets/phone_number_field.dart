import 'package:flutter/material.dart';

import '../../../core/data/countries.dart';
import '../../../core/theme/app_theme.dart';

// ── Phone Number Field ────────────────────────────────────────────────────────
// Numbers read left-to-right even inside an RTL app, so this field forces
// LTR internally (via a local Directionality override) regardless of the
// screen's overall direction. Layout, left → right:
//
//   [ 🇮🇷 +98 ▾ | 9121234567_______________ ]
//     ^ tap opens a small anchored dropdown (not a full sheet) with the
//       country list — see _pickCountry below.
//
// Design only — the composed number isn't read/submitted anywhere yet.

class PhoneNumberField extends StatefulWidget {
  const PhoneNumberField({super.key});

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  Country _selectedCountry = kCountries.first; // Iran, by default

  // Anchors the dropdown menu to the country chip specifically (not the
  // whole field), so it opens right under the flag/dial-code, not the input.
  final GlobalKey _countryButtonKey = GlobalKey();

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
      // Small, fixed-ish footprint — list scrolls internally past this.
      constraints: const BoxConstraints(maxHeight: 260, minWidth: 210),
      items: kCountries
          .map((country) => PopupMenuItem<Country>(
                value: country,
                height: 42,
                // Own RTL scope: this menu renders in the Overlay, above
                // LoginScreen's local Directionality, so it needs its own.
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextField(
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        // Fixes hint/typed text not sitting on the same vertical center as
        // the (taller) country chip prefix.
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          // Fixed on purpose — does NOT change based on the selected country
          // code. The app currently only launches in Iran, so a constant,
          // Iran-shaped example is clearer than trying to keep a per-country
          // example number in sync with the digit count of ~70 countries.
          hintText: '912 123 4567',
          hintTextDirection: TextDirection.ltr,
          // Lighter than the field's typed-text color on purpose — a hint
          // should read as a placeholder, not as if a number is already there.
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

// ── Country code chip (prefix) ────────────────────────────────────────────────

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
