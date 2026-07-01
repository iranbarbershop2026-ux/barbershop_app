// ── Intro Page Data ───────────────────────────────────────────────────────────
// Data model for each onboarding slide.
// Scenario: Discover → Book → Experience (3-slide arc)

class IntroPageData {
  final String imagePath; // asset path for the illustration image
  final String title;
  final String subtitle;

  const IntroPageData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });

  static const List<IntroPageData> pages = [
    IntroPageData(
      imagePath: 'assets/images/intro_icon1.png',
      title: 'آرایشگری که سبکت رو بفهمه',
      subtitle: 'پروفایل، نمونه‌کار و نظر مشتری‌ها رو ببین.\n'
          'قبل از رفتن انتخاب کن، نه بعد از پشیمونی',
    ),
    IntroPageData(
      imagePath: 'assets/images/intro_icon2.png',
      title: 'وقتت رو هدر نده',
      subtitle: 'بدون تماس تلفنی، بدون صف انتظار.\n'
          'هر وقت خواستی نوبت بگیر — در چند ثانیه',
    ),
    IntroPageData(
      imagePath: 'assets/images/intro_icon3.png',
      title: 'از آینه لذت ببر',
      subtitle: 'با کسی که می‌دونه تو چی می‌خوای.\n'
          'هر بار با اطمینان از آرایشگاه برگرد',
    ),
  ];
}
