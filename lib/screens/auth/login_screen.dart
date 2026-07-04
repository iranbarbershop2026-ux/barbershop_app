import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import 'widgets/barber_login_tab.dart';
import 'widgets/customer_login_tab.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _selectedTab = 0;

  // Controller اینجا زندگی می‌کنه — با جابجایی تب‌ها از بین نمیره
  final TextEditingController _customerPhoneController =
      TextEditingController();

  @override
  void dispose() {
    _customerPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppTheme.systemOverlay,
        child: Scaffold(
          backgroundColor: AppColors.bg,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final maxHeight = constraints.maxHeight;
                final isTablet = maxWidth >= 600;
                final horizontalPadding = isTablet ? 64.0 : 24.0;

                final formSection = _FormSection(
                  selectedTab: _selectedTab,
                  onTabSelect: (index) => setState(() => _selectedTab = index),
                  hPad: horizontalPadding,
                  isTablet: isTablet,
                  customerPhoneController: _customerPhoneController,
                );

                Widget branding = const Center(child: _AnimatedHeader());
                if (isTablet) {
                  branding = Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: branding,
                    ),
                  );
                }

                if (maxHeight > 500) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: branding),
                      formSection,
                    ],
                  );
                }

                Widget scrollContent = SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                      horizontalPadding, 36, horizontalPadding, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _AnimatedHeader(),
                      const SizedBox(height: 32),
                      _LoginTabBar(
                        selected: _selectedTab,
                        onSelect: (index) =>
                            setState(() => _selectedTab = index),
                      ),
                      const SizedBox(height: 20),
                      _AuthTabContent(
                        selectedTab: _selectedTab,
                        customerPhoneController: _customerPhoneController,
                      ),
                    ],
                  ),
                );

                if (isTablet) {
                  scrollContent = Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: scrollContent,
                    ),
                  );
                }

                return scrollContent;
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ── Form section ──────────────────────────────────────────────────────────────

class _FormSection extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabSelect;
  final double hPad;
  final bool isTablet;
  final TextEditingController customerPhoneController;

  const _FormSection({
    required this.selectedTab,
    required this.onTabSelect,
    required this.hPad,
    required this.isTablet,
    required this.customerPhoneController,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, isTablet ? 40 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LoginTabBar(selected: selectedTab, onSelect: onTabSelect),
          const SizedBox(height: 20),
          _AuthTabContent(
            selectedTab: selectedTab,
            customerPhoneController: customerPhoneController,
          ),
        ],
      ),
    );

    if (isTablet) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: content,
        ),
      );
    }

    return content;
  }
}

// ── Tab content ───────────────────────────────────────────────────────────────

class _AuthTabContent extends StatelessWidget {
  final int selectedTab;
  final TextEditingController customerPhoneController;

  const _AuthTabContent({
    required this.selectedTab,
    required this.customerPhoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Visibility(
          visible: false,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: IndexedStack(
            children: [
              BarberLoginTab(),
              CustomerLoginTab(phoneController: customerPhoneController),
            ],
          ),
        ),
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            layoutBuilder: (currentChild, previousChildren) => Stack(
              alignment: Alignment.topCenter,
              children: [
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            ),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.03, 0),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: selectedTab == 0
                ? CustomerLoginTab(
                    key: const ValueKey('customer'),
                    phoneController: customerPhoneController,
                  )
                : const BarberLoginTab(key: ValueKey('barber')),
          ),
        ),
      ],
    );
  }
}

// ── Animated header ───────────────────────────────────────────────────────────

class _AnimatedHeader extends StatefulWidget {
  const _AnimatedHeader();

  @override
  State<_AnimatedHeader> createState() => _AnimatedHeaderState();
}

class _AnimatedHeaderState extends State<_AnimatedHeader>
    with SingleTickerProviderStateMixin {
  static const _letters = ['R', 'E', 'B', 'R', 'A', 'B'];

  late final AnimationController _ctrl;
  late final List<Animation<double>> _letterFades;
  late final List<Animation<Offset>> _letterSlides;
  late final Animation<double> _dividerFrac;
  late final Animation<double> _subtitleOpacity;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _letterFades = List.generate(_letters.length, (i) {
      final start = i * 0.08;
      final end = (start + 0.24).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _ctrl, curve: Interval(start, end, curve: Curves.easeOut)),
      );
    });

    _letterSlides = List.generate(_letters.length, (i) {
      final start = i * 0.08;
      final end = (start + 0.30).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.55), end: Offset.zero)
          .animate(
        CurvedAnimation(
            parent: _ctrl,
            curve: Interval(start, end, curve: Curves.easeOutCubic)),
      );
    });

    _dividerFrac = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.58, 0.78, curve: Curves.easeOutCubic)),
    );

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.70, 0.92, curve: Curves.easeOut)),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _letters.length,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.5),
              child: FadeTransition(
                opacity: _letterFades[i],
                child: SlideTransition(
                  position: _letterSlides[i],
                  child: Text(
                    _letters[i],
                    style: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gold,
                      letterSpacing: 0,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        AnimatedBuilder(
          animation: _dividerFrac,
          builder: (_, __) => Container(
            width: 36 * _dividerFrac.value,
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.goldDim, AppColors.gold, AppColors.goldDim],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        FadeTransition(
          opacity: _subtitleOpacity,
          child: const Text(
            'برای ادامه وارد شوید',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tab bar ───────────────────────────────────────────────────────────────────

class _LoginTabBar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  static const _labels = ['ورود به عنوان مشتری', 'ورود به عنوان آرایشگاه'];

  const _LoginTabBar({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(
          _labels.length,
          (i) => _Tab(
            label: _labels[i],
            isActive: i == selected,
            onTap: () => onSelect(i),
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Tab(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 230),
          curve: Curves.easeInOutCubic,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.gold.withOpacity(0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isActive
                ? Border.all(color: AppColors.gold.withOpacity(0.28), width: 1)
                : null,
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 11.5,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.gold : AppColors.textSecondary,
                height: 1.3,
              ),
              child: Text(label, textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }
}
