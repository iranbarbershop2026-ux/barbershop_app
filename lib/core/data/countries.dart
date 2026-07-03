// ── Country Dial Codes ────────────────────────────────────────────────────────
// Data for the phone-number country picker (customer login tab).
//
// This is a curated list of commonly-needed countries (~70), not the full set
// of 195 sovereign states — Iran and its neighbours/region are prioritized
// since this is a Persian-language app. Adding a new country is a single line:
// just append a `Country(isoCode: ..., dialCode: ..., nameFa: ...)` below.
//
// Flags are NOT stored as data — they're computed on the fly from the ISO
// code (see `Country.flag`), so there's no image asset to keep in sync and no
// risk of a flag/code mismatch.

/// Converts a 2-letter ISO country code (e.g. 'IR') into its flag emoji by
/// mapping each letter to a Unicode Regional Indicator Symbol.
String _isoToFlagEmoji(String isoCode) {
  final codeUnits = isoCode.toUpperCase().codeUnits;
  const regionalIndicatorBase = 0x1F1E6; // 🇦
  const letterABase = 0x41; // 'A'
  return String.fromCharCodes(
    codeUnits.map((unit) => regionalIndicatorBase + (unit - letterABase)),
  );
}

class Country {
  final String isoCode;
  final String dialCode;
  final String nameFa;

  const Country({
    required this.isoCode,
    required this.dialCode,
    required this.nameFa,
  });

  String get flag => _isoToFlagEmoji(isoCode);
}

// ── Country list ────────────────────────────────────────────────────────────
// Iran first (default selection), then region, then rest of the world.
const List<Country> kCountries = [
  Country(isoCode: 'IR', dialCode: '98', nameFa: 'ایران'),

  // ── Middle East / neighbours ──────────────────────────────────────────────
  Country(isoCode: 'AF', dialCode: '93', nameFa: 'افغانستان'),
  Country(isoCode: 'IQ', dialCode: '964', nameFa: 'عراق'),
  Country(isoCode: 'TR', dialCode: '90', nameFa: 'ترکیه'),
  Country(isoCode: 'PK', dialCode: '92', nameFa: 'پاکستان'),
  Country(isoCode: 'AE', dialCode: '971', nameFa: 'امارات متحده عربی'),
  Country(isoCode: 'SA', dialCode: '966', nameFa: 'عربستان سعودی'),
  Country(isoCode: 'QA', dialCode: '974', nameFa: 'قطر'),
  Country(isoCode: 'KW', dialCode: '965', nameFa: 'کویت'),
  Country(isoCode: 'BH', dialCode: '973', nameFa: 'بحرین'),
  Country(isoCode: 'OM', dialCode: '968', nameFa: 'عمان'),
  Country(isoCode: 'SY', dialCode: '963', nameFa: 'سوریه'),
  Country(isoCode: 'LB', dialCode: '961', nameFa: 'لبنان'),
  Country(isoCode: 'JO', dialCode: '962', nameFa: 'اردن'),
  Country(isoCode: 'IL', dialCode: '972', nameFa: 'اسرائیل'),
  Country(isoCode: 'PS', dialCode: '970', nameFa: 'فلسطین'),
  Country(isoCode: 'EG', dialCode: '20', nameFa: 'مصر'),
  Country(isoCode: 'YE', dialCode: '967', nameFa: 'یمن'),

  // ── Caucasus / Central Asia ───────────────────────────────────────────────
  Country(isoCode: 'AZ', dialCode: '994', nameFa: 'آذربایجان'),
  Country(isoCode: 'AM', dialCode: '374', nameFa: 'ارمنستان'),
  Country(isoCode: 'GE', dialCode: '995', nameFa: 'گرجستان'),
  Country(isoCode: 'TM', dialCode: '993', nameFa: 'ترکمنستان'),
  Country(isoCode: 'UZ', dialCode: '998', nameFa: 'ازبکستان'),
  Country(isoCode: 'TJ', dialCode: '992', nameFa: 'تاجیکستان'),
  Country(isoCode: 'KZ', dialCode: '7', nameFa: 'قزاقستان'),
  Country(isoCode: 'KG', dialCode: '996', nameFa: 'قرقیزستان'),

  // ── Europe ────────────────────────────────────────────────────────────────
  Country(isoCode: 'GB', dialCode: '44', nameFa: 'بریتانیا'),
  Country(isoCode: 'DE', dialCode: '49', nameFa: 'آلمان'),
  Country(isoCode: 'FR', dialCode: '33', nameFa: 'فرانسه'),
  Country(isoCode: 'IT', dialCode: '39', nameFa: 'ایتالیا'),
  Country(isoCode: 'ES', dialCode: '34', nameFa: 'اسپانیا'),
  Country(isoCode: 'PT', dialCode: '351', nameFa: 'پرتغال'),
  Country(isoCode: 'NL', dialCode: '31', nameFa: 'هلند'),
  Country(isoCode: 'BE', dialCode: '32', nameFa: 'بلژیک'),
  Country(isoCode: 'CH', dialCode: '41', nameFa: 'سوئیس'),
  Country(isoCode: 'AT', dialCode: '43', nameFa: 'اتریش'),
  Country(isoCode: 'SE', dialCode: '46', nameFa: 'سوئد'),
  Country(isoCode: 'NO', dialCode: '47', nameFa: 'نروژ'),
  Country(isoCode: 'DK', dialCode: '45', nameFa: 'دانمارک'),
  Country(isoCode: 'FI', dialCode: '358', nameFa: 'فنلاند'),
  Country(isoCode: 'PL', dialCode: '48', nameFa: 'لهستان'),
  Country(isoCode: 'RU', dialCode: '7', nameFa: 'روسیه'),
  Country(isoCode: 'UA', dialCode: '380', nameFa: 'اوکراین'),
  Country(isoCode: 'GR', dialCode: '30', nameFa: 'یونان'),
  Country(isoCode: 'RO', dialCode: '40', nameFa: 'رومانی'),
  Country(isoCode: 'CZ', dialCode: '420', nameFa: 'جمهوری چک'),
  Country(isoCode: 'HU', dialCode: '36', nameFa: 'مجارستان'),
  Country(isoCode: 'IE', dialCode: '353', nameFa: 'ایرلند'),

  // ── Americas ──────────────────────────────────────────────────────────────
  Country(isoCode: 'US', dialCode: '1', nameFa: 'آمریکا'),
  Country(isoCode: 'CA', dialCode: '1', nameFa: 'کانادا'),
  Country(isoCode: 'MX', dialCode: '52', nameFa: 'مکزیک'),
  Country(isoCode: 'BR', dialCode: '55', nameFa: 'برزیل'),
  Country(isoCode: 'AR', dialCode: '54', nameFa: 'آرژانتین'),
  Country(isoCode: 'CL', dialCode: '56', nameFa: 'شیلی'),
  Country(isoCode: 'CO', dialCode: '57', nameFa: 'کلمبیا'),

  // ── Asia / Oceania ────────────────────────────────────────────────────────
  Country(isoCode: 'IN', dialCode: '91', nameFa: 'هند'),
  Country(isoCode: 'CN', dialCode: '86', nameFa: 'چین'),
  Country(isoCode: 'JP', dialCode: '81', nameFa: 'ژاپن'),
  Country(isoCode: 'KR', dialCode: '82', nameFa: 'کره جنوبی'),
  Country(isoCode: 'MY', dialCode: '60', nameFa: 'مالزی'),
  Country(isoCode: 'ID', dialCode: '62', nameFa: 'اندونزی'),
  Country(isoCode: 'TH', dialCode: '66', nameFa: 'تایلند'),
  Country(isoCode: 'PH', dialCode: '63', nameFa: 'فیلیپین'),
  Country(isoCode: 'VN', dialCode: '84', nameFa: 'ویتنام'),
  Country(isoCode: 'SG', dialCode: '65', nameFa: 'سنگاپور'),
  Country(isoCode: 'AU', dialCode: '61', nameFa: 'استرالیا'),
  Country(isoCode: 'NZ', dialCode: '64', nameFa: 'نیوزیلند'),

  // ── Africa ────────────────────────────────────────────────────────────────
  Country(isoCode: 'ZA', dialCode: '27', nameFa: 'آفریقای جنوبی'),
  Country(isoCode: 'NG', dialCode: '234', nameFa: 'نیجریه'),
  Country(isoCode: 'KE', dialCode: '254', nameFa: 'کنیا'),
  Country(isoCode: 'MA', dialCode: '212', nameFa: 'مراکش'),
  Country(isoCode: 'DZ', dialCode: '213', nameFa: 'الجزایر'),
  Country(isoCode: 'TN', dialCode: '216', nameFa: 'تونس'),
  Country(isoCode: 'LY', dialCode: '218', nameFa: 'لیبی'),
  Country(isoCode: 'SD', dialCode: '249', nameFa: 'سودان'),
  Country(isoCode: 'ET', dialCode: '251', nameFa: 'اتیوپی'),
];
