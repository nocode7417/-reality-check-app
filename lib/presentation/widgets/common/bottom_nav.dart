import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../providers/app_providers.dart';
import '../../navigation/app_router.dart';
import 'app_icons.dart';

/// Premium iOS-style bottom navigation with frosted glass effect
class BottomNav extends ConsumerWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bgSecondary.withOpacity(0),
            AppColors.bgSecondary.withOpacity(0.95),
            AppColors.bgSecondary,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none, // Allow overflow for elevated button
        children: [
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: EdgeInsets.only(
                  left: AppSpacing.navHorizontalPadding,
                  right: AppSpacing.navHorizontalPadding,
                  top: AppSpacing.navTopPadding,
                  bottom: AppSpacing.navBottomPadding + bottomPadding,
                ),
                decoration: BoxDecoration(
                  color: AppColors.glass,
                  border: Border(
                    top: BorderSide(
                      color: Colors.black.withOpacity(0.06),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Opacity(opacity: 0.0, child: SizedBox(height: 60)), // Invisible spacer for layout
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.navHorizontalPadding,
                right: AppSpacing.navHorizontalPadding,
                top: AppSpacing.navTopPadding,
                bottom: AppSpacing.navBottomPadding + bottomPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Semantics(
                    label: 'Home navigation button',
                    button: true,
                    enabled: true,
                    selected: currentIndex == 0,
                    child: _NavItem(
                      icon: AppIcons.home(
                        size: 22,
                        color: currentIndex == 0 ? AppColors.accent : AppColors.textMuted,
                      ),
                      label: 'Home',
                      isActive: currentIndex == 0,
                      onTap: () {
                        ref.read(navigationIndexProvider.notifier).state = 0;
                        context.go(AppRoutes.dashboard);
                      },
                    ),
                  ),
                  Semantics(
                    label: 'Log activity navigation button',
                    button: true,
                    enabled: true,
                    selected: currentIndex == 1,
                    child: _MainNavItem(
                      isActive: currentIndex == 1,
                      onTap: () {
                        ref.read(navigationIndexProvider.notifier).state = 1;
                        context.go(AppRoutes.log);
                      },
                    ),
                  ),
                  Semantics(
                    label: 'Calendar navigation button',
                    button: true,
                    enabled: true,
                    selected: currentIndex == 2,
                    child: _NavItem(
                      icon: AppIcons.calendar(
                        size: 22,
                        color: currentIndex == 2 ? AppColors.accent : AppColors.textMuted,
                      ),
                      label: 'Calendar',
                      isActive: currentIndex == 2,
                      onTap: () {
                        ref.read(navigationIndexProvider.notifier).state = 2;
                        context.go(AppRoutes.calendar);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final Widget icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        transform: Matrix4.identity()..scale(_isPressed ? 0.92 : 1.0),
        transformAlignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              transform: Matrix4.identity()
                ..translate(0.0, widget.isActive && !_isPressed ? -2.0 : 0.0),
              child: SizedBox(
                width: 44,
                height: 32,
                child: Center(child: widget.icon),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: AppTypography.navLabel(
                color: widget.isActive ? AppColors.accent : AppColors.textMuted,
              ).copyWith(
                fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            // Active indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              width: widget.isActive ? 5 : 0,
              height: widget.isActive ? 5 : 0,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainNavItem extends StatefulWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _MainNavItem({
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_MainNavItem> createState() => _MainNavItemState();
}

class _MainNavItemState extends State<_MainNavItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Elevated button
          Transform.translate(
            offset: const Offset(0, -AppSpacing.navButtonElevation),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              transform: Matrix4.identity()
                ..scale(_isPressed ? 0.95 : widget.isActive ? 1.0 : 1.08)
                ..translate(0.0, _isPressed ? 0.0 : -2.0),
              transformAlignment: Alignment.center,
              width: AppSpacing.navButtonSize,
              height: AppSpacing.navButtonSize,
              decoration: BoxDecoration(
                gradient: widget.isActive
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.accentDark, Color(0xFFB91C1C)],
                      )
                    : AppColors.accentGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(_isPressed ? 0.2 : 0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                  BoxShadow(
                    color: AppColors.accent.withOpacity(_isPressed ? 0.1 : 0.2),
                    offset: const Offset(0, 8),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: Center(
                child: AppIcons.plusCircle(size: 24, color: Colors.white),
              ),
            ),
          ),
          // Label
          Transform.translate(
            offset: const Offset(0, -AppSpacing.navButtonLabelOffset),
            child: Text(
              'Log',
              style: AppTypography.navLabel(
                color: widget.isActive ? AppColors.accent : AppColors.textSecondary,
              ).copyWith(
                fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}




