import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── رنگ‌ها ────────────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF111111);
  static const surface = Color(0xFF1C1C1C);
  static const gold = Color(0xFFC9A84C);
  static const goldDim = Color(0xFF9A7B35);
  static const goldBorder = Color(0x44C9A84C);
  static const goldBorderStrong = Color(0x88C9A84C);
  static const successGreen = Color(0xFF2ECC71);
  static const successBg = Color(0xFF1A3A2A);
  static const errorRed = Color(0xFFE74C3C);
  static const errorBg = Color(0xFF3A1A1A);
  static const textPrimary = Color(0xFFEEEEEE);
  static const textSecondary = Color(0xFF999999);
  static const textHint = Color(0xFF666666);
  static const divider = Color(0xFF2A2A2A);
  // گرادیان آبی‌تیره خیلی کم‌رنگ پشت کارت
  static const cardGlowTop = Color(0x001A3A5C);
}

// ── مدل داده ──────────────────────────────────────────────────────────────────
class BookingResult {
  final bool isSuccess;
  final String serviceLabel;
  final String serviceCategory;
  final String dateLabel;
  final String timeSlot;
  final String barberName;
  final String branchName;
  final String salonName;
  final String bookingCode;
  final int totalPrice;

  const BookingResult({
    required this.isSuccess,
    required this.serviceLabel,
    this.serviceCategory = 'مدل مو و پکیج',
    required this.dateLabel,
    required this.timeSlot,
    required this.barberName,
    required this.branchName,
    required this.salonName,
    required this.bookingCode,
    required this.totalPrice,
  });

  factory BookingResult.success() => const BookingResult(
        isSuccess: true,
        serviceLabel: 'اصلاح کلاسیک',
        serviceCategory: 'مدل مو و پکیج',
        dateLabel: 'شنبه ۱۲ تیر',
        timeSlot: '۱۷:۰۰',
        barberName: 'استاد افشین',
        branchName: 'نیاوران، مجتمع آریا',
        salonName: 'لوکس آروند',
        bookingCode: 'BK-7394-LXS',
        totalPrice: 250000,
      );

  factory BookingResult.failure() => const BookingResult(
        isSuccess: false,
        serviceLabel: 'اصلاح کلاسیک',
        serviceCategory: 'مدل مو و پکیج',
        dateLabel: 'شنبه ۱۲ تیر',
        timeSlot: '۱۷:۰۰',
        barberName: 'استاد افشین',
        branchName: 'نیاوران، مجتمع آریا',
        salonName: 'لوکس آروند',
        bookingCode: '',
        totalPrice: 250000,
      );
}

// ── ReceiptScreen ─────────────────────────────────────────────────────────────
class ReceiptScreen extends StatefulWidget {
  final BookingResult result;
  const ReceiptScreen({super.key, required this.result});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen>
    with TickerProviderStateMixin {
  late final AnimationController _iconCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  late final AnimationController _contentCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  );

  late final Animation<double> _iconScale = CurvedAnimation(
    parent: _iconCtrl,
    curve: Curves.elasticOut,
  );
  late final Animation<double> _contentOpacity = CurvedAnimation(
    parent: _contentCtrl,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _contentSlide = Tween(
    begin: const Offset(0, 0.05),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    _iconCtrl.forward().then((_) => _contentCtrl.forward());
  }

  @override
  void dispose() {
    _iconCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  bool get _ok => widget.result.isSuccess;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: _C.bg,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // آیکون وضعیت
                  ScaleTransition(
                    scale: _iconScale,
                    child: _StatusIcon(success: _ok),
                  ),
                  const SizedBox(height: 20),

                  // عنوان
                  Text(
                    _ok ? 'نوبت شما با موفقیت رزرو شد' : 'پرداخت ناموفق بود',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: _C.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _ok
                        ? 'منتظر حضور گرم شما در سالن ${widget.result.salonName} هستیم'
                        : 'مبلغی از حساب شما کسر نشده — لطفاً دوباره تلاش کنید',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _C.textSecondary,
                      height: 1.65,
                    ),
                  ),

                  const Spacer(flex: 1),

                  // کارت رسید
                  FadeTransition(
                    opacity: _contentOpacity,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: _ok
                          ? _SuccessCard(result: widget.result)
                          : _FailureCard(result: widget.result),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // دکمه بازگشت — outline
                  FadeTransition(
                    opacity: _contentOpacity,
                    child: _ok
                        ? _OutlineBtn(
                            label: 'بازگشت به خانه',
                            icon: Icons.home_rounded,
                            onTap: () => Navigator.of(context)
                                .popUntil((r) => r.isFirst),
                          )
                        : Column(children: [
                            _PrimaryBtn(
                              label: 'تلاش مجدد',
                              icon: Icons.refresh_rounded,
                              onTap: () => Navigator.pop(context),
                            ),
                            const SizedBox(height: 12),
                            _OutlineBtn(
                              label: 'بازگشت به خانه',
                              icon: Icons.home_rounded,
                              onTap: () => Navigator.of(context)
                                  .popUntil((r) => r.isFirst),
                            ),
                          ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── آیکون وضعیت ───────────────────────────────────────────────────────────────
class _StatusIcon extends StatelessWidget {
  final bool success;
  const _StatusIcon({required this.success});

  @override
  Widget build(BuildContext context) {
    final color = success ? _C.successGreen : _C.errorRed;
    final bg = success ? _C.successBg : _C.errorBg;
    return Center(
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bg,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(
          success ? Icons.check_rounded : Icons.close_rounded,
          size: 32,
          color: color,
        ),
      ),
    );
  }
}

// ── کارت موفق ─────────────────────────────────────────────────────────────────
class _SuccessCard extends StatelessWidget {
  final BookingResult result;
  const _SuccessCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // گرادیان آبی‌تیره خیلی کم‌رنگ از پایین به بالا
        gradient: const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color.fromARGB(35, 65, 254, 163), _C.cardGlowTop],
        ),
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        border: Border.all(color: _C.goldBorder, width: 1.2),
      ),
      child: Container(
        decoration: BoxDecoration(
            color: _C.surface.withOpacity(0.92),
            borderRadius: const BorderRadius.all(Radius.circular(18))),
        child: Column(
          children: [
            // ── بدنه اصلی با نوار طلایی داخلی ────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: Column(
                children: [
                  // نوار طلایی — داخل کارت، چسبیده به بالا
                  Container(
                    height: 3,
                    width: double.infinity,
                    margin:
                        const EdgeInsets.only(bottom: 28, right: 24, left: 24),
                    decoration: const BoxDecoration(
                      color: _C.gold,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(3),
                        bottomRight: Radius.circular(3),
                      ),
                    ),
                  ),

                  // ردیف بالا: سرویس راست | قیمت چپ
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // نام سرویس — سمت راست
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            result.serviceCategory,
                            style: const TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 10,
                              color: _C.textHint,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            result.serviceLabel,
                            style: const TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: _C.gold,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // قیمت — سمت چپ
                      Text(
                        _formatPrice(result.totalPrice),
                        style: const TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _C.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: _C.divider, height: 1, thickness: 1),
                  const SizedBox(height: 22),

                  // ردیف ۱: ساعت چپ | تاریخ راست
                  Row(
                    children: [
                      Expanded(
                        child: _DetailCell(
                          label: 'تاریخ ملاقات',
                          value: result.dateLabel,
                          valueColor: _C.gold,
                          align: CrossAxisAlignment.start,
                        ),
                      ),
                      const SizedBox(width: 34),
                      Expanded(
                        child: _DetailCell(
                          label: 'ساعت رزرو شده',
                          value: result.timeSlot,
                          valueColor: _C.gold,
                          align: CrossAxisAlignment.start,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ردیف ۲: شعبه چپ | آرایشگر راست
                  Row(
                    children: [
                      Expanded(
                        child: _DetailCell(
                          label: 'آرایشگر مسئول',
                          value: result.barberName,
                          valueColor: _C.textPrimary,
                          align: CrossAxisAlignment.start,
                        ),
                      ),
                      const SizedBox(width: 34),
                      Expanded(
                        child: _DetailCell(
                          label: 'شعبه مرکزی',
                          value: result.branchName,
                          valueColor: _C.textPrimary,
                          align: CrossAxisAlignment.start,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── جداکننده دندانه‌دار ────────────────────────────────
            _TornEdge(),

            // ── بارکد باریک + کد ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 10, 32, 14),
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: CustomPaint(painter: _BarcodePainter()),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    result.bookingCode,
                    style: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 11,
                      letterSpacing: 2.5,
                      color: _C.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── کارت ناموفق ───────────────────────────────────────────────────────────────
class _FailureCard extends StatelessWidget {
  final BookingResult result;
  const _FailureCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0x183A1A1A), Color(0x003A1A1A)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.errorRed.withOpacity(0.35), width: 1.2),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _C.surface.withOpacity(0.92),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            // نوار قرمز بالا
            Container(
              height: 3,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12, right: 42, left: 42),
              decoration: const BoxDecoration(
                color: _C.errorRed,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(3),
                  bottomRight: Radius.circular(3),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'مدل مو و پکیج',
                            style: TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 10,
                              color: _C.textHint,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            result.serviceLabel,
                            style: const TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _C.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        _formatPrice(result.totalPrice),
                        style: const TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _C.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: _C.divider, height: 1, thickness: 1),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _DetailCell(
                          label: 'تاریخ',
                          value: result.dateLabel,
                          valueColor: _C.textPrimary,
                          align: CrossAxisAlignment.start,
                        ),
                      ),
                      const SizedBox(width: 34),
                      Expanded(
                        child: _DetailCell(
                          label: 'ساعت',
                          value: result.timeSlot,
                          valueColor: _C.textPrimary,
                          align: CrossAxisAlignment.start,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _C.errorRed.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _C.errorRed.withOpacity(0.25)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 1),
                          child: Icon(Icons.error_outline_rounded,
                              size: 15, color: _C.errorRed),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'تراکنش ناموفق — مبلغی کسر نشده است.\nدر صورت تکرار مشکل با پشتیبانی تماس بگیرید.',
                            style: TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 11,
                              color: _C.errorRed,
                              height: 1.65,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── سلول جزئیات ───────────────────────────────────────────────────────────────
class _DetailCell extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final CrossAxisAlignment align;

  const _DetailCell({
    required this.label,
    required this.value,
    required this.valueColor,
    this.align = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 10,
            color: _C.textHint,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// ── جداکننده دندانه‌دار ───────────────────────────────────────────────────────
class _TornEdge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 20,
            decoration: const BoxDecoration(
              color: _C.bg,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
          ),
          Expanded(
            child: CustomPaint(painter: _DashLinePainter()),
          ),
          Container(
            width: 10,
            height: 20,
            decoration: const BoxDecoration(
              color: _C.bg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _C.goldBorderStrong
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    const dashWidth = 6.0;
    const gapWidth = 4.0;
    double x = 0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dashWidth, y), paint);
      x += dashWidth + gapWidth;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── بارکد ─────────────────────────────────────────────────────────────────────
class _BarcodePainter extends CustomPainter {
  static const _widths = [
    3,
    1,
    4,
    1,
    5,
    2,
    3,
    2,
    4,
    1,
    3,
    2,
    5,
    1,
    4,
    2,
    3,
    1,
    2,
    4,
    3,
    2,
    1,
    4,
    5,
    1,
    3,
    2,
    4,
    1,
    5,
    2,
    3,
    1,
    4,
    2,
    3,
    1,
    5,
    2,
    4,
    1,
    3,
    2,
    4,
    3,
    1,
    5,
    2,
    3,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final barPaint = Paint()..color = _C.textPrimary;
    double x = 0;
    bool isBar = true;
    for (final w in _widths) {
      final barWidth = w * 2.1;
      if (isBar) {
        canvas.drawRect(
          Rect.fromLTWH(x, 0, barWidth, size.height),
          barPaint,
        );
      }
      x += barWidth + 0.7;
      isBar = !isBar;
      if (x > size.width) break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── دکمه Outline (بازگشت به خانه) ────────────────────────────────────────────
class _OutlineBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlineBtn({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_OutlineBtn> createState() => _OutlineBtnState();
}

class _OutlineBtnState extends State<_OutlineBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 52,
          decoration: BoxDecoration(
            color: _pressed ? _C.gold.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _pressed ? _C.gold : _C.goldBorderStrong,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 17, color: _C.gold),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _C.gold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── دکمه Primary (تلاش مجدد) ─────────────────────────────────────────────────
class _PrimaryBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryBtn({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_PrimaryBtn> createState() => _PrimaryBtnState();
}

class _PrimaryBtnState extends State<_PrimaryBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 52,
          decoration: BoxDecoration(
            color: _pressed ? _C.goldDim : _C.gold,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 17, color: _C.bg),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _C.bg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── فرمت قیمت ─────────────────────────────────────────────────────────────────
String _formatPrice(int price) {
  final s = price.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('٬');
    buf.write(s[i]);
  }
  var result = '$buf تومان';
  const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  for (var i = 0; i < en.length; i++) {
    result = result.replaceAll(en[i], fa[i]);
  }
  return result;
}

// ── تست سریع ──────────────────────────────────────────────────────────────────
void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ReceiptScreen(result: BookingResult.success()),
    ),
  );
}
