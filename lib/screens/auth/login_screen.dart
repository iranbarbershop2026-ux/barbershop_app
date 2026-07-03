import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import 'widgets/barber_login_tab.dart';
import 'widgets/customer_login_tab.dart';

// ── Login Screen ──────────────────────────────────────────────────────────────
// Entry point for user authentication — two tabs: آرایشگاه · مشتری
//
// ── Layout ───────────────────────────────────────────────────────────────────
//   Top section    : animated BARBER brand (Expanded — fills available space)
//   Bottom section : tab bar + form fields (pinned to bottom)
//   Tablet         : centred column, max-width 480px
//
// ── Micro interactions ────────────────────────────────────────────────────────
//   1. BARBER letters stagger in — each slides up + fades (80ms delay/letter)
//   2. Gold divider extends from 0 → 36px after last letter settles
//   3. Subtitle fades in after divider completes
//   All three play once on mount; screen stays static thereafter.

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    // TODO: move this to MaterialApp (e.g. via locale: Locale('fa') +
    // flutter_localizations) so the whole app is RTL, not just this screen.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppTheme.systemOverlay,
        child: Scaffold(
          backgroundColor: AppColors.bg,
          // Let keyboard push content: fields stay accessible when keyboard opens
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                final isTablet = w >= 600;
                final hPad = isTablet ? 64.0 : 24.0;

                // ── Form section (tab bar + content) ───────────────────────
                final formSection = _FormSection(
                  selectedTab: _selectedTab,
                  onTabSelect: (i) => setState(() => _selectedTab = i),
                  hPad: hPad,
                  isTablet: isTablet,
                );

                // ── Branding section (animated header) ──────────────────────
                Widget branding = const Center(child: _AnimatedHeader());
                if (isTablet) {
                  branding = Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: branding,
                    ),
                  );
                }

                // ── Tall screen: fixed layout ───────────────────────────────
                // Branding fills all space above the form — bottom third is form.
                if (h > 500) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top: brand (takes whatever space the form doesn't need)
                      Expanded(child: branding),
                      // Bottom: tab bar + form fields
                      formSection,
                    ],
                  );
                }

                // ── Short screen: scroll fallback ───────────────────────────
                Widget scrollContent = SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(hPad, 36, hPad, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _AnimatedHeader(),
                      const SizedBox(height: 32),
                      _LoginTabBar(
                        selected: _selectedTab,
                        onSelect: (i) => setState(() => _selectedTab = i),
                      ),
                      const SizedBox(height: 20),
                      _tabContent,
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

  Widget get _tabContent => _AuthTabContent(selectedTab: _selectedTab);
}

// ── Form Section ──────────────────────────────────────────────────────────────
// Tab bar + animated content. Pinned to the bottom of the screen.

class _FormSection extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabSelect;
  final double hPad;
  final bool isTablet;

  const _FormSection({
    required this.selectedTab,
    required this.onTabSelect,
    required this.hPad,
    required this.isTablet,
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
          _AuthTabContent(selectedTab: selectedTab),
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

// ── Auth Tab Content ───────────────────────────────────────────────────────────
// Cross-fades between BarberLoginTab and CustomerLoginTab.
//
// The barbershop tab has more fields than the customer tab, so switching
// naively made this block shrink/grow — which pushed the branding section
// above it (Expanded) up or down, making the whole screen jump.
//
// Fix: an invisible IndexedStack lays out BOTH tabs purely to measure them.
// IndexedStack always sizes itself to its *largest* child, regardless of
// which index is selected — so this widget's height is pinned to whichever
// tab is taller, and never changes when switching. The real, visible content
// sits on top via Positioned.fill and animates normally.

class _AuthTabContent extends StatelessWidget {
  final int selectedTab;

  const _AuthTabContent({required this.selectedTab});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Sizing-only: never painted, never hit-tested — just reserves space.
        const Visibility(
          visible: false,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: IndexedStack(
            children: [BarberLoginTab(), CustomerLoginTab()],
          ),
        ),
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            // Keep both the outgoing and incoming child top-aligned within
            // the reserved space (default AnimatedSwitcher alignment is
            // centered, which would visually re-center shorter content).
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
                ? const BarberLoginTab(key: ValueKey('barber'))
                : const CustomerLoginTab(key: ValueKey('customer')),
          ),
        ),
      ],
    );
  }
}

// ── Animated Header ───────────────────────────────────────────────────────────
// Three-phase entry animation, plays once on mount:
//   Phase 1 (0–65%): letters stagger in — slide up + fade, 80ms between each
//   Phase 2 (58–78%): gold divider extends from 0 to 36px
//   Phase 3 (68–90%): subtitle fades in

class _AnimatedHeader extends StatefulWidget {
  const _AnimatedHeader();

  @override
  State<_AnimatedHeader> createState() => _AnimatedHeaderState();
}

class _AnimatedHeaderState extends State<_AnimatedHeader>
    with SingleTickerProviderStateMixin {
  static const _letters = ['R', 'E', 'B', 'R', 'A', 'B'];

  late final AnimationController _ctrl;

  // Per-letter fade (0→1) and slide (Offset(0, 0.5) → zero)
  late final List<Animation<double>> _letterFades;
  late final List<Animation<Offset>> _letterSlides;

  // Divider width as a fraction (0→1), scaled to 36px in build
  late final Animation<double> _dividerFrac;

  // Subtitle opacity
  late final Animation<double> _subtitleOpacity;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // Each letter starts 8% (≈88ms) after the previous
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
      return Tween<Offset>(
        begin: const Offset(0, 0.55),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
            parent: _ctrl,
            curve: Interval(start, end, curve: Curves.easeOutCubic)),
      );
    });

    // Divider appears after last letter settles (~58%)
    _dividerFrac = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.58, 0.78, curve: Curves.easeOutCubic)),
    );

    // Subtitle fades after divider
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
        // ── Staggered BARBER letters ─────────────────────────────────────
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
                  )),
        ),

        const SizedBox(height: 14),

        // ── Extending gold divider ───────────────────────────────────────
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

        // ── Subtitle ─────────────────────────────────────────────────────
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

// ── Tab Bar ───────────────────────────────────────────────────────────────────

class _LoginTabBar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  static const _labels = ['ورود به عنوان آرایشگاه', 'ورود به عنوان مشتری'];

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
