import 'package:barbershop_app/screens/booking/receipt_screen.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../core/theme/app_theme.dart';

// ── Booking Screen v3 ─────────────────────────────────────────────────────────

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late Jalali _currentMonth;
  int? _selectedDayIndex;
  String? _selectedSlot;
  final Set<int> _selectedServices = {};
  final _notesCtrl = TextEditingController();

  static const _slots = [
    '۹:۰۰',
    '۹:۳۰',
    '۱۰:۰۰',
    '۱۰:۳۰',
    '۱۱:۰۰',
    '۱۱:۳۰',
    '۱۲:۰۰',
    '۱۲:۳۰',
    '۱۳:۰۰',
    '۱۳:۳۰',
    '۱۴:۰۰',
    '۱۴:۳۰',
    '۱۵:۰۰',
    '۱۵:۳۰',
    '۱۶:۰۰',
    '۱۶:۳۰',
    '۱۷:۰۰',
    '۱۷:۳۰',
  ];
  static const _unavailable = {'۱۰:۳۰', '۱۲:۰۰', '۱۴:۰۰', '۱۶:۰۰'};

  static const _services = [
    _Svc('اصلاح سر', 30, 150000),
    _Svc('اصلاح صورت', 20, 80000),
    _Svc('اصلاح ریش', 15, 60000),
    _Svc('رنگ مو', 60, 350000),
    _Svc('ماساژ سر', 20, 100000),
    _Svc('روتین پوستی', 40, 220000),
    _Svc('خدمات داماد', 120, 1200000),
  ];

  @override
  void initState() {
    super.initState();
    _currentMonth = Jalali.now();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  List<Jalali> get _days {
    return List.generate(
      _currentMonth.monthLength,
      (i) => Jalali(_currentMonth.year, _currentMonth.month, i + 1),
    );
  }

  Jalali? get _selDay =>
      _selectedDayIndex != null ? _days[_selectedDayIndex!] : null;

  int get _totalMin =>
      _selectedServices.fold(0, (s, i) => s + _services[i].duration);
  int get _totalPrice =>
      _selectedServices.fold(0, (s, i) => s + _services[i].price);
  bool get _canPay =>
      _selDay != null && _selectedSlot != null && _selectedServices.isNotEmpty;

  void _changeMonth(int delta) => setState(() {
        _selectedDayIndex = null;
        _selectedSlot = null;
        var m = _currentMonth.month + delta;
        var y = _currentMonth.year;
        if (m > 12) {
          m = 1;
          y++;
        }
        if (m < 1) {
          m = 12;
          y--;
        }
        _currentMonth = Jalali(y, m, 1);
      });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(children: [
            _AppBar(onBack: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── ۱. انتخاب ماه/سال ────────────────────────────────
                    _MonthYearPicker(
                      month: _currentMonth,
                      onPrev: () => _changeMonth(-1),
                      onNext: () => _changeMonth(1),
                      onMonthTap: _showMonthSheet,
                      onYearTap: _showYearSheet,
                    ),
                    const SizedBox(height: 16),

                    // ── ۲. لیست روزها ─────────────────────────────────────
                    _DayList(
                      days: _days,
                      selectedIndex: _selectedDayIndex,
                      today: Jalali.now(),
                      onSelect: (i) => setState(() {
                        _selectedDayIndex = i;
                        _selectedSlot = null;
                      }),
                    ),

                    // ── ۳. ساعت‌ها ────────────────────────────────────────
                    if (_selDay != null) ...[
                      const SizedBox(height: 24),
                      _Label(text: 'انتخاب ساعت — ${_dayLabel(_selDay!)}'),
                      const SizedBox(height: 10),
                      _TimeGrid(
                        slots: _slots,
                        unavailable: _unavailable,
                        selected: _selectedSlot,
                        onSelect: (s) => setState(() => _selectedSlot = s),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // ── ۴. خدمات ──────────────────────────────────────────
                    const _Label(text: 'خدمات مورد نیاز'),
                    const SizedBox(height: 10),
                    _ServicesGrid(
                      services: _services,
                      selected: _selectedServices,
                      onToggle: (i) => setState(() =>
                          _selectedServices.contains(i)
                              ? _selectedServices.remove(i)
                              : _selectedServices.add(i)),
                    ),

                    // ── ۵. رسید ───────────────────────────────────────────
                    if (_selectedServices.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _Receipt(
                        day: _selDay,
                        slot: _selectedSlot,
                        services:
                            _selectedServices.map((i) => _services[i]).toList(),
                        totalMin: _totalMin,
                        totalPrice: _totalPrice,
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ── ۶. یادداشت ────────────────────────────────────────
                    _NotesField(controller: _notesCtrl),
                    const SizedBox(height: 28),

                    // ── ۷. پرداخت ─────────────────────────────────────────
                    _PayButton(
                      enabled: _canPay,
                      onTap: () {},
                      isLoading: false,
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Month sheet ───────────────────────────────────────────────────────────
  void _showMonthSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: _PickerSheet(
          title: 'انتخاب ماه',
          items: _monthNames,
          selectedIndex: _currentMonth.month - 1,
          onSelect: (i) => setState(() {
            _selectedDayIndex = null;
            _selectedSlot = null;
            _currentMonth = Jalali(_currentMonth.year, i + 1, 1);
          }),
        ),
      ),
    );
  }

  // ── Year sheet ────────────────────────────────────────────────────────────
  void _showYearSheet() {
    final now = Jalali.now();
    final years = List.generate(5, (i) => now.year + i);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: _PickerSheet(
          title: 'انتخاب سال',
          items: years.map((y) => _fa(y.toString())).toList(),
          selectedIndex: years.indexOf(_currentMonth.year),
          onSelect: (i) => setState(() {
            _selectedDayIndex = null;
            _selectedSlot = null;
            _currentMonth = Jalali(years[i], _currentMonth.month, 1);
          }),
        ),
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final VoidCallback onBack;
  const _AppBar({required this.onBack});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
        child: Stack(alignment: Alignment.center, children: [
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onBack,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.chevron_left_rounded,
                    size: 26, color: AppColors.textSecondary),
              ),
            ),
          ),
          const Text('رزرو نوبت',
              style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ]),
      );
}

// ── Month/year picker ─────────────────────────────────────────────────────────
// کاربر می‌تواند روی ماه یا سال تپ کند — sheet انتخابی باز می‌شود.

class _MonthYearPicker extends StatelessWidget {
  final Jalali month;
  final VoidCallback onPrev, onNext, onMonthTap, onYearTap;
  const _MonthYearPicker({
    required this.month,
    required this.onPrev,
    required this.onNext,
    required this.onMonthTap,
    required this.onYearTap,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NavBtn(icon: Icons.chevron_right_rounded, onTap: onPrev),
          const SizedBox(width: 10),
          // ماه — قابل تپ
          GestureDetector(
            onTap: onMonthTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(_monthNames[month.month - 1],
                    style: const TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(width: 4),
                const Icon(Icons.expand_more_rounded,
                    size: 16, color: AppColors.textHint),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          // سال — قابل تپ
          GestureDetector(
            onTap: onYearTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(_fa(month.year.toString()),
                    style: const TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(width: 4),
                const Icon(Icons.expand_more_rounded,
                    size: 16, color: AppColors.textHint),
              ]),
            ),
          ),
          const SizedBox(width: 10),
          _NavBtn(icon: Icons.chevron_left_rounded, onTap: onNext),
        ],
      );
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
      );
}

// ── Generic picker sheet ──────────────────────────────────────────────────────

class _PickerSheet extends StatelessWidget {
  final String title;
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  const _PickerSheet(
      {required this.title,
      required this.items,
      required this.selectedIndex,
      required this.onSelect});

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.55),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 10),
          Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (_, i) => ListTile(
                onTap: () {
                  onSelect(i);
                  Navigator.pop(context);
                },
                title: Text(items[i],
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 14,
                      fontWeight: i == selectedIndex
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: i == selectedIndex
                          ? AppColors.gold
                          : AppColors.textPrimary,
                    )),
                trailing: i == selectedIndex
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.gold, size: 18)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ]),
      );
}

// ── Day list ──────────────────────────────────────────────────────────────────

class _DayList extends StatefulWidget {
  final List<Jalali> days;
  final int? selectedIndex;
  final Jalali today;
  final ValueChanged<int> onSelect;
  const _DayList(
      {required this.days,
      required this.selectedIndex,
      required this.today,
      required this.onSelect});

  @override
  State<_DayList> createState() => _DayListState();
}

class _DayListState extends State<_DayList> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final i = widget.days.indexWhere((d) =>
          d.day == widget.today.day &&
          d.month == widget.today.month &&
          d.year == widget.today.year);
      if (i >= 0 && _scroll.hasClients) {
        _scroll.animateTo(i * 68.0,
            duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 110,
        child: ListView.separated(
          controller: _scroll,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: widget.days.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final d = widget.days[i];
            final isToday = d.day == widget.today.day &&
                d.month == widget.today.month &&
                d.year == widget.today.year;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _DayPill(
                day: d,
                isToday: isToday,
                isSelected: i == widget.selectedIndex,
                onTap: () => widget.onSelect(i),
              ),
            );
          },
        ),
      );
}

class _DayPill extends StatelessWidget {
  final Jalali day;
  final bool isToday, isSelected;
  final VoidCallback onTap;
  const _DayPill(
      {required this.day,
      required this.isToday,
      required this.isSelected,
      required this.onTap});

  static const _wd = [
    'شنبه',
    'یکشنبه',
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنجشنبه',
    'جمعه'
  ];

  @override
  Widget build(BuildContext context) {
    Color bg, textColor, borderColor;
    if (isSelected) {
      bg = AppColors.gold;
      textColor = AppColors.bg;
      borderColor = AppColors.gold;
    } else if (isToday) {
      bg = AppColors.gold.withOpacity(0.10);
      textColor = AppColors.gold;
      borderColor = AppColors.gold.withOpacity(0.45);
    } else {
      bg = AppColors.surface;
      textColor = AppColors.textSecondary;
      borderColor = AppColors.border.withOpacity(0.2);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: 52,
        decoration: BoxDecoration(
          color: bg,
          // کاهش radius طبق درخواست
          borderRadius: BorderRadius.circular(32.0),
          border: Border.all(color: borderColor, width: isSelected ? 0 : 1),
          // سایه خیلی کمتر
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppColors.gold.withOpacity(0.12),
                      blurRadius: 1,
                      spreadRadius: 4,
                      offset: const Offset(0, 0))
                ]
              : null,
        ),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(_wd[(day.weekDay - 1) % 7],
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? AppColors.bg.withOpacity(0.95)
                      : AppColors.textHint,
                )),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white70
                  : Colors.white70.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(_fa(day.day.toString()),
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    )),
              ),
            ),
          ),
          if (isToday && !isSelected) ...[
            const SizedBox(height: 3),
            Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                    color: AppColors.gold, shape: BoxShape.circle)),
          ],
        ]),
      ),
    );
  }
}

// ── Time grid ─────────────────────────────────────────────────────────────────

class _TimeGrid extends StatelessWidget {
  final List<String> slots;
  final Set<String> unavailable;
  final String? selected;
  final ValueChanged<String> onSelect;
  const _TimeGrid(
      {required this.slots,
      required this.unavailable,
      required this.selected,
      required this.onSelect});

  @override
  Widget build(BuildContext context) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          // childAspectRatio بزرگ‌تر = ارتفاع کمتر، جلوگیری از overflow
          childAspectRatio: 2.6,
          mainAxisSpacing: 7,
          crossAxisSpacing: 7,
        ),
        itemCount: slots.length,
        itemBuilder: (_, i) {
          final s = slots[i];
          final taken = unavailable.contains(s);
          final active = s == selected;
          return GestureDetector(
            onTap: taken ? null : () => onSelect(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.gold
                    : taken
                        ? AppColors.surface.withOpacity(0.05)
                        : AppColors.surface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: active
                      ? AppColors.gold
                      : taken
                          ? AppColors.border.withOpacity(0.05)
                          : AppColors.border.withOpacity(0.02),
                ),
              ),
              child: Center(
                child: Text(s,
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 12,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                      color: active
                          ? AppColors.bg
                          : taken
                              ? AppColors.textHint.withOpacity(0.35)
                              : AppColors.textSecondary,
                      decoration: taken ? TextDecoration.lineThrough : null,
                    )),
              ),
            ),
          );
        },
      );
}

// ── Services grid ─────────────────────────────────────────────────────────────

class _ServicesGrid extends StatelessWidget {
  final List<_Svc> services;
  final Set<int> selected;
  final ValueChanged<int> onToggle;
  const _ServicesGrid(
      {required this.services, required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8, crossAxisSpacing: 8,
          // ارتفاع کافی برای جلوگیری از overflow متن
          childAspectRatio: 2.0,
        ),
        itemCount: services.length,
        itemBuilder: (_, i) => _SvcCard(
          item: services[i],
          isSelected: selected.contains(i),
          onTap: () => onToggle(i),
        ),
      );
}

class _SvcCard extends StatelessWidget {
  final _Svc item;
  final bool isSelected;
  final VoidCallback onTap;
  const _SvcCard(
      {required this.item, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          // lift effect: بالا می‌آید
          transform: Matrix4.translationValues(0, isSelected ? -3 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.gold.withOpacity(0.09)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.gold : AppColors.border,
              width: isSelected ? 1.4 : 1,
            ),
            // سایه خیلی سبک
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: AppColors.gold.withOpacity(0.14),
                        blurRadius: 4,
                        spreadRadius: 1,
                        offset: const Offset(0, 2))
                  ]
                : [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.gold : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected ? AppColors.gold : AppColors.border,
                      width: 1.2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          size: 10, color: AppColors.bg)
                      : null,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
              const SizedBox(height: 5),
              Row(children: [
                Text('${_fa(item.duration.toString())} دقیقه',
                    style: const TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 10,
                        color: AppColors.textHint)),
                const Spacer(),
                Text(_price(item.price),
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? AppColors.gold : AppColors.textSecondary,
                    )),
              ]),
            ],
          ),
        ),
      );
}

// ── Receipt ───────────────────────────────────────────────────────────────────

class _Receipt extends StatelessWidget {
  final Jalali? day;
  final String? slot;
  final List<_Svc> services;
  final int totalMin, totalPrice;
  const _Receipt(
      {required this.day,
      required this.slot,
      required this.services,
      required this.totalMin,
      required this.totalPrice});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGold),
        ),
        padding: const EdgeInsets.all(14),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: const [
            Icon(Icons.receipt_long_rounded, size: 13, color: AppColors.gold),
            SizedBox(width: 6),
            Text('خلاصه رزرو',
                style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold)),
          ]),
          const SizedBox(height: 10),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 10),
          if (day != null)
            _Row(
                label: 'تاریخ',
                value:
                    '${_fa(day!.day.toString())} ${_monthNames[day!.month - 1]} ${_fa(day!.year.toString())}'),
          if (slot != null) _Row(label: 'ساعت', value: slot!),
          const SizedBox(height: 6),
          ...services.map(
              (s) => _Row(label: s.name, value: _price(s.price), dim: true)),
          const SizedBox(height: 6),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 8),
          _Row(label: 'مدت تقریبی', value: '${_fa(totalMin.toString())} دقیقه'),
          const SizedBox(height: 4),
          Row(children: [
            const Text('جمع کل',
                style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const Spacer(),
            Text(_price(totalPrice),
                style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold)),
          ]),
        ]),
      );
}

class _Row extends StatelessWidget {
  final String label, value;
  final bool dim;
  const _Row({required this.label, required this.value, this.dim = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(children: [
          Text(label,
              style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 11,
                  color: dim ? AppColors.textHint : AppColors.textSecondary)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 11,
                  fontWeight: dim ? FontWeight.w400 : FontWeight.w600,
                  color: dim ? AppColors.textHint : AppColors.textPrimary)),
        ]),
      );
}

// ── Notes field ───────────────────────────────────────────────────────────────

class _NotesField extends StatelessWidget {
  final TextEditingController controller;
  const _NotesField({required this.controller});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان با آیکون سوال
          const Row(children: [
            Text('دیگه چی؟',
                style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            SizedBox(width: 6),
            Icon(Icons.help_outline_rounded,
                size: 14, color: AppColors.textHint),
            SizedBox(width: 6),
            Flexible(
              child: Text('اختیاری',
                  style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 11,
                      color: AppColors.textHint)),
            ),
          ]),
          const SizedBox(height: 6),
          // placeholder hint معنادار
          TextField(
            controller: controller,
            maxLines: 3,
            maxLength: 300,
            textAlign: TextAlign.right,
            style: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.7),
            decoration: const InputDecoration(
              hintText:
                  'مثلاً: ۵ دقیقه دیرتر می‌رسم · استایل خاصی در نظر دارم · حساسیت پوستی دارم یا ..',
              hintStyle: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 12,
                  color: AppColors.textHint,
                  height: 1.6),
              hintMaxLines: 3,
              counterStyle: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 10,
                  color: AppColors.textHint),
            ),
          ),
        ],
      );
}

// ── Pay button — با پشتیبانی از حالت loading ─────────────────────────────────

class _PayButton extends StatefulWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;
  const _PayButton({
    required this.enabled,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_PayButton> createState() => _PayButtonState();
}

class _PayButtonState extends State<_PayButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          // Payment is disabled, but for testing, navigate to the receipt screen with a failed booking result.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReceiptScreen(
                result: BookingResult(
                    isSuccess: false,
                    serviceLabel: 'کوتاهی مو',
                    dateLabel: 'سه شنبه ۲۵ فروردین ۱۴۰۲',
                    timeSlot: '۱۶:۳۰ - ۱۷:۰۰',
                    barberName: 'علی رضایی',
                    branchName: 'نیاوران (شعبه ۱)',
                    salonName: 'آرایشگاه مردانه آریا',
                    bookingCode: 'B-E247676',
                    totalPrice: 500000),
              ),
            ),
          );
        },
        onTapDown: widget.enabled && !widget.isLoading
            ? (_) => setState(() => _pressed = true)
            : null,
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 110),
          child: AnimatedOpacity(
            opacity: widget.enabled ? 1.0 : 0.38,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 130),
              height: 52,
              decoration: BoxDecoration(
                color: _pressed ? AppColors.goldDim : AppColors.gold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: widget.isLoading
                    // حالت loading — spinner جای متن
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.bg),
                        ),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.payment_rounded,
                              size: 17, color: AppColors.bg),
                          SizedBox(width: 8),
                          Text(
                            'ادامه و پرداخت',
                            style: TextStyle(
                                fontFamily: 'Vazirmatn',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.bg),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      );
}

// ── Label ─────────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary));
}

// ── Models ────────────────────────────────────────────────────────────────────

class _Svc {
  final String name;
  final int duration, price;
  const _Svc(this.name, this.duration, this.price);
}

// ── Helpers ───────────────────────────────────────────────────────────────────

const _monthNames = [
  'فروردین',
  'اردیبهشت',
  'خرداد',
  'تیر',
  'مرداد',
  'شهریور',
  'مهر',
  'آبان',
  'آذر',
  'دی',
  'بهمن',
  'اسفند',
];

String _fa(String s) {
  const e = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const f = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  for (var i = 0; i < e.length; i++) s = s.replaceAll(e[i], f[i]);
  return s;
}

String _price(int p) {
  final s = p.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return _fa('${buf} ت');
}

String _dayLabel(Jalali d) =>
    '${_fa(d.day.toString())} ${_monthNames[d.month - 1]}';
