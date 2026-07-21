import 'package:barbershop_app/screens/booking/booking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_theme.dart';

// ── Barbershop Detail Screen ──────────────────────────────────────────────────
// انیمیشن ورود:
//   • Hero image از کارت home به بالای صفحه می‌رود (Flutter built-in Hero)
//   • همزمان محتوای زیر تصویر با SlideTransition از پایین + FadeTransition
//     ظاهر می‌شود — این حس «جعبه‌ای باز شد» را می‌دهد
//
// برای dial/map: flutter pub add url_launcher

class BarbershopDetailScreen extends StatefulWidget {
  final BarbershopData shop;
  final String heroTag;

  const BarbershopDetailScreen({
    super.key,
    required this.shop,
    required this.heroTag,
  });

  @override
  State<BarbershopDetailScreen> createState() => _BarbershopDetailScreenState();
}

class _BarbershopDetailScreenState extends State<BarbershopDetailScreen>
    with SingleTickerProviderStateMixin {
  int _imageIndex = 0;
  final PageController _pageCtrl = PageController();

  // کنترلر انیمیشن slide-in محتوا
  late final AnimationController _contentCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  late final Animation<Offset> _contentSlide = Tween<Offset>(
    begin: const Offset(0, 0.12), // از پایین کمی
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _contentCtrl,
    curve: Curves.easeOutCubic,
  ));
  late final Animation<double> _contentFade = CurvedAnimation(
    parent: _contentCtrl,
    curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    // Hero duration تقریباً ۳۸۰ms است — کمی بعدش محتوا شروع می‌کند
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentCtrl.forward();
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shop = widget.shop;
    final screenH = MediaQuery.of(context).size.height;
    final sliderH = screenH * 0.36;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.bg,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.bg,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // ── Image slider (Hero) ───────────────────────────────
                  SliverToBoxAdapter(
                    child: _ImageSlider(
                      images: shop.images,
                      height: sliderH,
                      currentIndex: _imageIndex,
                      controller: _pageCtrl,
                      heroTag: widget.heroTag,
                      onPageChanged: (i) => setState(() => _imageIndex = i),
                      onBack: () => Navigator.of(context).pop(),
                      isVip: shop.isVip,
                    ),
                  ),

                  // ── محتوا — slide-in از پایین ─────────────────────────
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _contentFade,
                      child: SlideTransition(
                        position: _contentSlide,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _NameRatingBlock(shop: shop),
                              const SizedBox(height: 16),
                              _sectionDivider,
                              const SizedBox(height: 16),
                              _StatusHoursRow(shop: shop),
                              const SizedBox(height: 16),
                              _sectionDivider,
                              const SizedBox(height: 16),
                              _ServicesBlock(services: shop.services),
                              const SizedBox(height: 16),
                              _sectionDivider,
                              const SizedBox(height: 16),
                              _ContactBlock(shop: shop),
                              const SizedBox(height: 16),
                              _sectionDivider,
                              const SizedBox(height: 16),
                              _LocationBlock(
                                address: shop.address,
                                lat: shop.lat,
                                lng: shop.lng,
                              ),
                              const SizedBox(height: 16),
                              _sectionDivider,
                              const SizedBox(height: 16),
                              _ReviewsBlock(
                                rating: shop.rating,
                                reviewCount: shop.reviewCount,
                                reviews: shop.reviews,
                              ),
                              SizedBox(height: 88 + bottomPad),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Sticky bottom bar ─────────────────────────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: FadeTransition(
                  opacity: _contentFade,
                  child: _BottomBar(bottomPad: bottomPad),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── divider ───────────────────────────────────────────────────────────────────
// کم‌رنگ‌تر از قبل — border را با 0.4 opacity می‌زنیم
const _sectionDivider = Divider(
  color: Color(0x662A2A2A), // AppColors.border با opacity پایین
  thickness: 1,
  height: 1,
);

// ── Image Slider ──────────────────────────────────────────────────────────────

class _ImageSlider extends StatelessWidget {
  final List<String> images;
  final double height;
  final int currentIndex;
  final PageController controller;
  final String heroTag;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onBack;
  final bool isVip;

  const _ImageSlider({
    required this.images,
    required this.height,
    required this.currentIndex,
    required this.controller,
    required this.heroTag,
    required this.onPageChanged,
    required this.onBack,
    required this.isVip,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // ── صفحات تصویر ──────────────────────────────────────────────
          PageView.builder(
            controller: controller,
            onPageChanged: onPageChanged,
            itemCount: images.length,
            itemBuilder: (_, i) {
              final img = Image.asset(
                images[i],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.surfaceElevated,
                  child: const Center(
                    child: Icon(Icons.storefront_outlined,
                        color: AppColors.textHint, size: 44),
                  ),
                ),
              );
              return i == 0 ? Hero(tag: heroTag, child: img) : img;
            },
          ),

          // ── gradient بالا ─────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topPad + 80,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.65),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── soft black fade overlay (covers ~25% bottom of image) ─────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: height * 0.25,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.00), // شروع کاملاً شفاف
                    Colors.black.withValues(alpha: 0.20), // فید خیلی نرم
                    Colors.black.withValues(alpha: 0.35), // تاریکی ملایم
                    Colors.black.withValues(alpha: 0.55), // پایین کمی تیره‌تر
                  ],
                  stops: const [0.0, 0.40, 0.70, 1.0],
                ),
              ),
            ),
          ),

          // ── gradient پایین — fade به bg ───────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.bg.withValues(alpha: 0.55),
                    AppColors.bg,
                  ],
                  stops: const [0.48, 0.80, 1.0],
                ),
              ),
            ),
          ),

          // ── دکمه برگشت + VIP badge ───────────────────────────────────
          Positioned(
            top: topPad + 8,
            left: 16,
            right: 16,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  _GlassButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: onBack,
                  ),
                  const Spacer(),
                  if (isVip)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'سالن ویژه',
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.bg,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── dot indicators ─────────────────────────────────────────────
          if (images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) {
                  final active = i == currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.gold
                          : Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

// ── Name + Rating ─────────────────────────────────────────────────────────────

class _NameRatingBlock extends StatelessWidget {
  final BarbershopData shop;
  const _NameRatingBlock({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          shop.name,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ..._stars(shop.rating),
            const SizedBox(width: 8),
            Text(
              shop.rating.toStringAsFixed(1),
              style: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(${shop.reviewCount} نظر)',
              style: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          shop.about,
          style: const TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 12.5,
            color: AppColors.textSecondary,
            height: 1.75,
          ),
        ),
      ],
    );
  }

  List<Widget> _stars(double rating) {
    return List.generate(5, (i) {
      final full = rating.floor();
      final frac = rating - full;
      IconData ico;
      if (i < full) {
        ico = Icons.star_rounded;
      } else if (i == full && frac >= 0.25 && frac < 0.75) {
        ico = Icons.star_half_rounded;
      } else if (i == full && frac >= 0.75) {
        ico = Icons.star_rounded;
      } else {
        ico = Icons.star_border_rounded;
      }
      return Icon(ico, size: 18, color: AppColors.gold);
    });
  }
}

// ── Status + Hours ────────────────────────────────────────────────────────────

class _StatusHoursRow extends StatelessWidget {
  final BarbershopData shop;
  const _StatusHoursRow({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (shop.isOnline) ...[
          _OnlineDot(),
          const SizedBox(width: 6),
          const Text('آنلاین',
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4CAF50),
              )),
          const SizedBox(width: 18),
        ],
        const Icon(Icons.access_time_rounded,
            size: 14, color: AppColors.textHint),
        const SizedBox(width: 5),
        Text(
          'ساعات کاری: ${shop.hours}',
          style: const TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _OnlineDot extends StatefulWidget {
  @override
  State<_OnlineDot> createState() => _OnlineDotState();
}

class _OnlineDotState extends State<_OnlineDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50)
                  .withValues(alpha: 0.2 + _ctrl.value * 0.5),
              blurRadius: 4 + _ctrl.value * 6,
              spreadRadius: _ctrl.value * 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Services ──────────────────────────────────────────────────────────────────
// لیست خطی ساده با تیک طلایی — بدون باکس، دو ستونه با Wrap

class _ServicesBlock extends StatelessWidget {
  final List<String> services;
  const _ServicesBlock({required this.services});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle(title: 'خدمات سالن'),
        const SizedBox(height: 12),
        // دو ستون با GridView سبک — بدون هیچ دکوری
        _ServicesGrid(services: services),
      ],
    );
  }
}

class _ServicesGrid extends StatelessWidget {
  final List<String> services;
  const _ServicesGrid({required this.services});

  @override
  Widget build(BuildContext context) {
    // تقسیم به دو ستون دستی با Row+Column تا نیاز به SliverGrid نباشد
    final mid = (services.length / 2).ceil();
    final col1 = services.sublist(0, mid);
    final col2 = services.sublist(mid);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _ServiceColumn(items: col1)),
        const SizedBox(width: 12),
        Expanded(child: _ServiceColumn(items: col2)),
      ],
    );
  }
}

class _ServiceColumn extends StatelessWidget {
  final List<String> items;
  const _ServiceColumn({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const Icon(Icons.check_rounded,
                        size: 14, color: AppColors.gold),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s,
                        style: const TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

// ── Contact ───────────────────────────────────────────────────────────────────
// تلفن: tap روی کل row → launchUrl با scheme tel:
// آدرس: متن ساده

class _ContactBlock extends StatelessWidget {
  final BarbershopData shop;
  const _ContactBlock({required this.shop});

  Future<void> _dial(String rawPhone) async {
    final digits = rawPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(scheme: 'tel', path: digits);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── تلفن (قابل کلیک) ──────────────────────────────────────────
        GestureDetector(
          onTap: () => _dial(shop.phone),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone_rounded,
                    size: 16, color: AppColors.gold),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('تلفن تماس',
                          style: TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 10,
                              color: AppColors.textHint)),
                      const SizedBox(height: 2),
                      // نمایش شماره در LTR تا درست نمایش داده شود
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          shop.phone,
                          style: const TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // آیکن نشانه‌دهنده که کلیک‌پذیر است
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.call_rounded,
                      size: 16, color: AppColors.gold),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ── آدرس (متن ساده) ───────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: AppColors.gold),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('آدرس',
                        style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 10,
                            color: AppColors.textHint)),
                    const SizedBox(height: 2),
                    Text(
                      shop.address,
                      style: const TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Location ──────────────────────────────────────────────────────────────────
// micro-interaction: scale bounce هنگام tap

class _LocationBlock extends StatefulWidget {
  final String address;
  final double lat, lng;
  const _LocationBlock(
      {required this.address, required this.lat, required this.lng});

  @override
  State<_LocationBlock> createState() => _LocationBlockState();
}

class _LocationBlockState extends State<_LocationBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 140),
    lowerBound: 0.96,
    upperBound: 1.0,
    value: 1.0,
  );

  Future<void> _openMapSheet() async {
    // bounce
    await _pulseCtrl.reverse();
    await _pulseCtrl.forward();
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: _MapPickerSheet(
          lat: widget.lat,
          lng: widget.lng,
          address: widget.address,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle(title: 'لوکیشن و نقشه سالن'),
        const SizedBox(height: 14),
        ScaleTransition(
          scale: _pulseCtrl,
          child: GestureDetector(
            onTap: _openMapSheet,
            child: Container(
              height: 165,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned.fill(
                      child: CustomPaint(painter: _MapGridPainter())),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.40),
                                blurRadius: 14,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.location_on_rounded,
                              color: AppColors.bg, size: 22),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.bg.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Text('برای مسیریابی لمس کنید',
                              style: TextStyle(
                                fontFamily: 'Vazirmatn',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              )),
                        ),
                        const SizedBox(height: 4),
                        const Text('گوگل‌مپ  ·  ویز  ·  نشان',
                            style: TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 10,
                              color: AppColors.textHint,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MapPickerSheet extends StatelessWidget {
  final double lat, lng;
  final String address;
  const _MapPickerSheet(
      {required this.lat, required this.lng, required this.address});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          const Text('انتخاب اپ مسیریابی',
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              )),
          const SizedBox(height: 16),
          _MapOption(
            label: 'گوگل‌مپ',
            icon: Icons.map_rounded,
            onTap: () => _launch(
                'https://www.google.com/maps/search/?api=1&query=$lat,$lng'),
          ),
          const SizedBox(height: 10),
          _MapOption(
            label: 'ویز',
            icon: Icons.navigation_rounded,
            onTap: () => _launch('waze://?ll=$lat,$lng&navigate=yes'),
          ),
          const SizedBox(height: 10),
          _MapOption(
            label: 'نشان',
            icon: Icons.location_on_rounded,
            onTap: () => _launch('https://maps.google.com/?q=$lat,$lng'),
          ),
        ],
      ),
    );
  }
}

class _MapOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _MapOption(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.gold),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              )),
        ]),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = AppColors.border.withValues(alpha: 0.45)
      ..strokeWidth = 0.7;
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    final road = Paint()
      ..color = AppColors.surfaceElevated
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height * 0.35),
        Offset(size.width, size.height * 0.62), road);
    canvas.drawLine(Offset(size.width * 0.3, 0),
        Offset(size.width * 0.55, size.height), road);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Reviews ───────────────────────────────────────────────────────────────────
// micro-interaction: هر کارت با hover/press یک scale کوچک می‌خورد

class _ReviewsBlock extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final List<ReviewItem> reviews;
  const _ReviewsBlock(
      {required this.rating, required this.reviewCount, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          const _SectionTitle(title: 'نظرات مشتریان'),
          const Spacer(),
          Row(children: [
            const Icon(Icons.star_rounded, color: AppColors.gold, size: 13),
            const SizedBox(width: 4),
            Text(
              '${rating.toStringAsFixed(1)} از $reviewCount نظر',
              style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 11,
                  color: AppColors.textHint),
            ),
          ]),
        ]),
        const SizedBox(height: 14),
        SizedBox(
          height: 155,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            // padding بیشتر برای کاهش حس شلوغی
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _ReviewCard(review: reviews[i]),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatefulWidget {
  final ReviewItem review;
  const _ReviewCard({required this.review});

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: 205,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            // border کم‌رنگ‌تر
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.35),
                        width: 1.2),
                  ),
                  child: Center(
                    child: Text(
                      widget.review.name[0],
                      style: const TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.review.name,
                          style: const TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      // تاریخ زیر نام
                      Text(widget.review.date,
                          style: const TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 9.5,
                              color: AppColors.textHint)),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(
                children: List.generate(
                    5,
                    (i) => Icon(
                          i < widget.review.stars
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 12,
                          color: i < widget.review.stars
                              ? AppColors.gold
                              : AppColors.border,
                        )),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(widget.review.text,
                    style: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3,
          height: 15,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            )),
      ],
    );
  }
}

// ── Sticky bottom bar ─────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final double bottomPad;
  const _BottomBar({required this.bottomPad});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPad + 12),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
      ),
      child: Row(
        children: [
          _ActionButton(
            label: 'فروشگاه',
            icon: Icons.storefront_outlined,
            outlined: true,
            onTap: () {},
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionButton(
              label: 'رزرو نوبت',
              icon: Icons.calendar_month_rounded,
              outlined: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BookingScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool outlined;
  final VoidCallback onTap;
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.outlined,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: widget.outlined
                ? Colors.transparent
                : (_pressed ? AppColors.goldDim : AppColors.gold),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.outlined
                  ? (_pressed ? AppColors.gold : AppColors.border)
                  : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon,
                  size: 14,
                  color: widget.outlined
                      ? (_pressed ? AppColors.gold : AppColors.textSecondary)
                      : AppColors.bg),
              const SizedBox(width: 6),
              Text(widget.label,
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: widget.outlined
                        ? (_pressed ? AppColors.gold : AppColors.textSecondary)
                        : AppColors.bg,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class BarbershopData {
  final String name, address, phone, hours, about;
  final List<String> images;
  final List<String> services;
  final double rating, distanceKm, lat, lng;
  final int reviewCount, priceTier;
  final bool isVip, isOnline;
  final List<ReviewItem> reviews;

  const BarbershopData({
    required this.name,
    required this.address,
    required this.phone,
    required this.hours,
    required this.about,
    required this.images,
    required this.services,
    required this.rating,
    required this.distanceKm,
    required this.lat,
    required this.lng,
    required this.reviewCount,
    required this.priceTier,
    required this.isVip,
    required this.isOnline,
    required this.reviews,
  });
}

class ReviewItem {
  final String name, text, date;
  final int stars;
  const ReviewItem({
    required this.name,
    required this.text,
    required this.date,
    required this.stars,
  });
}

// ── Mock factory ──────────────────────────────────────────────────────────────

BarbershopData mockShopFromCard({
  required String name,
  required String address,
  required double rating,
  required int reviews,
  required double distance,
  required String hours,
  required bool isVip,
  required int price,
  required String image,
}) {
  return BarbershopData(
    name: name,
    address: address,
    phone: '02188100990',
    hours: hours,
    about:
        'لوکس‌ترین هیر استودیو در شمال تهران با سرویس پذیرایی اختصاصی، متدهای اصلاح کلاسیک بریتانیایی و مجرب‌ترین کادر پیرایشی کشور.',
    // سه اسلاید با عکس‌های مختلف از همون asset folder
    images: [
      image,
      'assets/images/barbershop_detail_2.jpg',
      'assets/images/barbershop_detail_3.jpg',
    ],
    services: const [
      'اصلاح سر',
      'اصلاح صورت',
      'اصلاح ریش',
      'خدمات داماد',
      'رنگ مو',
      'فیشیال صورت',
      'ماساژ سر',
    ],
    rating: rating,
    distanceKm: distance,
    lat: 35.7219,
    lng: 51.3347,
    reviewCount: reviews,
    priceTier: price,
    isVip: isVip,
    isOnline: true,
    reviews: const [
      ReviewItem(
        name: 'امیررضا ک.',
        text: 'بهترین هیرکات زندگیم رو تجربه کردم. استایل دهی بسیار حرفه‌ای.',
        date: '۱۴۰۳/۰۴/۱۲',
        stars: 5,
      ),
      ReviewItem(
        name: 'احسان محمدی',
        text: 'محیط بسیار شیک با خدمات درجه یک. حتماً برمی‌گردم.',
        date: '۱۴۰۳/۰۳/۲۸',
        stars: 5,
      ),
      ReviewItem(
        name: 'سینا رضوی',
        text: 'کار حرفه‌ای و دقیق. دقیقاً همان چیزی که می‌خواستم.',
        date: '۱۴۰۳/۰۳/۰۵',
        stars: 4,
      ),
      ReviewItem(
        name: 'کوروش م.',
        text: 'رزرو آنلاین خیلی راحت. وقت‌شناس و برخورد بسیار خوب.',
        date: '۱۴۰۳/۰۲/۱۹',
        stars: 5,
      ),
    ],
  );
}
