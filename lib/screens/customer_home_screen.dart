import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_theme.dart';

// ── Customer Home Screen ───────────────────────────────────────────────────────
// Design phase — all data is static mock, no network calls.

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _navIndex = 2;
  int _filterIndex = 0;
  String _city = 'استان تهران';

  static const _cities = [
    'استان تهران',
    'اصفهان',
    'مشهد',
    'شیراز',
    'تبریز',
    'ساوه',
    'بندرعباس',
    'اهواز',
    'کرج',
    'قم',
  ];

  static const _filters = [
    'محبوب‌ترین',
    'نزدیک‌ترین',
    'ارزان‌ترین',
    'گران‌ترین',
    'VIP',
  ];

  static final _shops = <_Shop>[
    const _Shop(
        name: 'عمارت زیبایی آروند',
        address: 'زعفرانیه، مجتمع فرشته، واحد ۳',
        rating: 4.9,
        reviews: 128,
        distance: 1.2,
        hours: '۹ تا ۲۱',
        isVip: true,
        price: 3,
        image: 'assets/images/barbershop1.jpg'),
    const _Shop(
        name: 'سالن کینگ کات',
        address: 'الهیه، خیابان مریم شرقی، پلاک ۴۴',
        rating: 4.8,
        reviews: 96,
        distance: 2.4,
        hours: '۱۰ تا ۲۲',
        isVip: true,
        price: 3,
        image: 'assets/images/barbershop2.jpg'),
    const _Shop(
        name: 'آرایشگاه مدرن نیاوران',
        address: 'نیاوران، خیابان باهنر، پلاک ۱۲',
        rating: 4.6,
        reviews: 74,
        distance: 3.8,
        hours: '۹ تا ۲۰',
        isVip: false,
        price: 2,
        image: 'assets/images/barbershop3.jpg'),
    const _Shop(
        name: 'استایل پلاس جردن',
        address: 'جردن، خیابان آفریقا، کوچه ۱۳',
        rating: 4.5,
        reviews: 61,
        distance: 4.1,
        hours: '۱۰ تا ۲۱',
        isVip: false,
        price: 2,
        image: 'assets/images/barbershop4.jpg'),
    const _Shop(
        name: 'باربر شاپ کلاسیک ونک',
        address: 'ونک، میدان ونک، برج سپهر، طبقه ۲',
        rating: 4.4,
        reviews: 43,
        distance: 5.5,
        hours: '۸ تا ۲۰',
        isVip: false,
        price: 1,
        image: 'assets/images/barbershop5.jpg'),
    const _Shop(
        name: 'آرایشگاه ستاره پونک',
        address: 'پونک، بلوار اشرفی اصفهانی',
        rating: 4.2,
        reviews: 29,
        distance: 7.2,
        hours: '۹ تا ۲۰',
        isVip: false,
        price: 1,
        image: 'assets/images/barbershop6.jpg'),
    const _Shop(
        name: 'گلد کات تجریش',
        address: 'تجریش، خیابان شریعتی، پلاک ۸',
        rating: 4.7,
        reviews: 88,
        distance: 6.0,
        hours: '۱۰ تا ۲۲',
        isVip: true,
        price: 3,
        image: 'assets/images/barbershop7.jpg'),
    const _Shop(
        name: 'پریمیوم کات فرشته',
        address: 'فرشته، خیابان ولنجک، واحد ۵',
        rating: 4.3,
        reviews: 51,
        distance: 3.2,
        hours: '۹ تا ۲۱',
        isVip: false,
        price: 2,
        image: 'assets/images/barbershop8.jpg'),
    const _Shop(
        name: 'آرایشگاه رویال سعادت‌آباد',
        address: 'سعادت‌آباد، میدان کاج',
        rating: 4.1,
        reviews: 37,
        distance: 8.5,
        hours: '۸ تا ۱۹',
        isVip: false,
        price: 1,
        image: 'assets/images/barbershop9.jpg'),
  ];

  List<_Shop> get _sorted {
    final list = List<_Shop>.from(_shops);
    switch (_filterIndex) {
      case 0:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case 1:
        list.sort((a, b) => a.distance.compareTo(b.distance));
      case 2:
        list.sort((a, b) => a.price.compareTo(b.price));
      case 3:
        list.sort((a, b) => b.price.compareTo(a.price));
      case 4:
        return list.where((s) => s.isVip).toList();
    }
    return list;
  }

  void _pickCity() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: _CitySheet(
          cities: _cities,
          selected: _city,
          onPick: (c) => setState(() => _city = c),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.systemOverlay,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Column(children: [
              _TopBar(city: _city, onCityTap: _pickCity),
              const SizedBox(height: 20),
              _SectionHeader(city: _city),
              const SizedBox(height: 14),
              _FilterRow(
                filters: _filters,
                selected: _filterIndex,
                onSelect: (i) => setState(() => _filterIndex = i),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: _ShopList(
                  key: ValueKey(_filterIndex),
                  shops: _sorted,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String city;
  final VoidCallback onCityTap;
  const _TopBar({required this.city, required this.onCityTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(children: [
        // Avatar
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
            border: Border.all(color: AppColors.borderGold, width: 1.5),
          ),
          child: const Icon(Icons.person_outline_rounded,
              color: AppColors.gold, size: 20),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('پروفایل کاربر',
                style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 10,
                    color: AppColors.textHint)),
            Text('شاهین آریا',
                style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ],
        ),
        const Spacer(),
        // City selector
        GestureDetector(
          onTap: onCityTap,
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('موقعیت فعلی',
                  style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 10,
                      color: AppColors.textHint)),
              const SizedBox(height: 2),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text(city,
                    style: const TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold)),
                const SizedBox(width: 3),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.gold, size: 16),
              ]),
              Container(
                height: 1,
                margin: const EdgeInsets.only(top: 2),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [AppColors.goldDim, AppColors.gold]),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String city;
  const _SectionHeader({required this.city});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 20, left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('پیشنهاد برترین آرایشگاه‌ها',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('مجموعه سالن‌های با کلاس کاری ممتاز در $city',
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5)),
          ],
        ),
      );
}

// ── Filter chips row ──────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final List<String> filters;
  final int selected;
  final ValueChanged<int> onSelect;
  const _FilterRow(
      {required this.filters, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => _Chip(
            label: filters[i],
            active: selected == i,
            onTap: () => onSelect(i),
          ),
        ),
      );
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color:
                active ? AppColors.gold.withOpacity(0.12) : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: active ? AppColors.gold : AppColors.border, width: 1.2),
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active ? AppColors.gold : AppColors.textSecondary,
              ),
              child: Text(label),
            ),
          ),
        ),
      );
}

// ── Animated shop list ────────────────────────────────────────────────────────

class _ShopList extends StatelessWidget {
  final List<_Shop> shops;
  const _ShopList({super.key, required this.shops});

  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 2, 20, 24),
        itemCount: shops.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) => _StaggeredCard(shop: shops[i], index: i),
      );
}

// ── Staggered entry wrapper ───────────────────────────────────────────────────

class _StaggeredCard extends StatefulWidget {
  final _Shop shop;
  final int index;
  const _StaggeredCard({required this.shop, required this.index});

  @override
  State<_StaggeredCard> createState() => _StaggeredCardState();
}

class _StaggeredCardState extends State<_StaggeredCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _ctrl,
    curve: Interval((widget.index * 0.06).clamp(0, 0.5), 1.0,
        curve: Curves.easeOut),
  );
  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0.05, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _ctrl,
    curve: Interval((widget.index * 0.06).clamp(0, 0.5), 1.0,
        curve: Curves.easeOutCubic),
  ));

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.index * 45), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _opacity,
        child: SlideTransition(
            position: _slide, child: _ShopCard(shop: widget.shop)),
      );
}

// ── Shop card ─────────────────────────────────────────────────────────────────

class _ShopCard extends StatefulWidget {
  final _Shop shop;
  const _ShopCard({required this.shop});

  @override
  State<_ShopCard> createState() => _ShopCardState();
}

class _ShopCardState extends State<_ShopCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.shop;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {/* TODO: navigate to detail */},
      child: AnimatedScale(
        scale: _pressed ? 0.972 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            // No border — depth comes from shadow alone
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.55),
                blurRadius: 18,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          // ── Single Stack: caption sits ON TOP of image ───────────────────
          // This is the only way to get a true seamless fade — when image and
          // caption are siblings in a Column there is always a hard pixel
          // boundary between them regardless of gradient settings.
          child: Stack(
            children: [
              // Full-card image
              SizedBox(
                width: double.infinity,
                height: 220,
                child: Image.asset(
                  s.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.surfaceElevated,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.storefront_outlined,
                              color: AppColors.textHint, size: 32),
                          const SizedBox(height: 6),
                          Text(s.name.split(' ').first,
                              style: const TextStyle(
                                  fontFamily: 'Vazirmatn',
                                  fontSize: 11,
                                  color: AppColors.textHint)),
                        ]),
                  ),
                ),
              ),

              // Gradient overlay — transparent at top, surface-color at bottom.
              // Covers the bottom 55% of the card so caption reads perfectly.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.surface.withOpacity(0.15),
                        AppColors.surface.withOpacity(0.80),
                        AppColors.surface,
                      ],
                      stops: const [0.35, 0.58, 0.76, 1.0],
                    ),
                  ),
                ),
              ),

              // VIP badge — top-left
              if (s.isVip)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('VIP',
                        style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.bg)),
                  ),
                ),

              // Rating badge — top-right
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bg.withOpacity(0.70),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderGold),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.gold, size: 12),
                    const SizedBox(width: 3),
                    Text(s.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gold)),
                  ]),
                ),
              ),

              // Caption — overlaid at bottom of the stack
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name,
                          style: const TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      _InfoRow(
                          icon: Icons.location_on_outlined, text: s.address),
                      const SizedBox(height: 8),
                      Row(children: [
                        _StatItem(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: '${s.reviews} نظر'),
                        _statDivider,
                        _StatItem(
                            icon: Icons.near_me_outlined,
                            label: '${_kmFa(s.distance)} فاصله'),
                        _statDivider,
                        _StatItem(
                            icon: Icons.access_time_rounded, label: s.hours),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textHint),
          const SizedBox(width: 4),
          Flexible(
              child: Text(text,
                  style: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 11,
                      color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
        ],
      );
}

// ── Stat item (inside card footer) ───────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.gold.withOpacity(0.7)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary)),
        ],
      );
}

const _statDivider = Padding(
  padding: EdgeInsets.symmetric(horizontal: 10),
  child: SizedBox(
      height: 12,
      child: VerticalDivider(color: AppColors.border, thickness: 1, width: 1)),
);

/// Converts a double km value to a Persian-readable string.
/// Examples: 1.2 → "۱.۲ کیلومتر", 0.8 → "۸۰۰ متر"
String _kmFa(double km) {
  if (km < 1.0) {
    return '${(km * 1000).round()} متر';
  }
  final formatted =
      km == km.roundToDouble() ? '${km.round()}' : km.toStringAsFixed(1);
  return '$formatted کیلومتر';
}

// ── City picker sheet ─────────────────────────────────────────────────────────

class _CitySheet extends StatelessWidget {
  final List<String> cities;
  final String selected;
  final ValueChanged<String> onPick;
  const _CitySheet(
      {required this.cities, required this.selected, required this.onPick});

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        // Constrain height so it never overflows on small screens
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 10),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 14),
          const Text('انتخاب شهر',
              style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...cities.map((c) => ListTile(
                        onTap: () {
                          onPick(c);
                          Navigator.pop(context);
                        },
                        trailing: c == selected
                            ? const Icon(Icons.check_rounded,
                                color: AppColors.gold, size: 18)
                            : null,
                        title: Text(c,
                            style: TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 14,
                              fontWeight: c == selected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: c == selected
                                  ? AppColors.gold
                                  : AppColors.textPrimary,
                            )),
                      )),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ]),
      );
}

// ── Data model ────────────────────────────────────────────────────────────────

class _Shop {
  final String name, address, hours, image;
  final double rating, distance;
  final int reviews, price;
  final bool isVip;

  const _Shop({
    required this.name,
    required this.address,
    required this.hours,
    required this.image,
    required this.rating,
    required this.distance,
    required this.reviews,
    required this.price,
    required this.isVip,
  });
}
