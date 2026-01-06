import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import 'app_icons.dart';

/// StatCard variant types
enum StatCardVariant { defaultVariant, accent, productive, hero }

/// StatCard size types
enum StatCardSize { small, medium, large, hero }

/// Premium iOS-style stat card widget
class StatCard extends StatefulWidget {
  final Widget? icon;
  final String? title;
  final String value;
  final String? subtitle;
  final String? trend; // 'up', 'down', or null
  final String? trendValue;
  final StatCardVariant variant;
  final StatCardSize size;
  final VoidCallback? onTap;
  final int staggerIndex;

  const StatCard({
    super.key,
    this.icon,
    this.title,
    required this.value,
    this.subtitle,
    this.trend,
    this.trendValue,
    this.variant = StatCardVariant.defaultVariant,
    this.size = StatCardSize.medium,
    this.onTap,
    this.staggerIndex = 0,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Stagger animation start
    Future.delayed(Duration(milliseconds: 50 * widget.staggerIndex), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
          onTapUp: widget.onTap != null ? (_) => setState(() => _isPressed = false) : null,
          onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
            decoration: _buildDecoration(),
            padding: _buildPadding(),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    Gradient? gradient;
    
    switch (widget.variant) {
      case StatCardVariant.accent:
        gradient = AppColors.cardAccentGradient;
        break;
      case StatCardVariant.productive:
        gradient = AppColors.cardProductiveGradient;
        break;
      case StatCardVariant.hero:
        gradient = AppColors.heroGradient;
        break;
      default:
        break;
    }

    return BoxDecoration(
      color: gradient == null ? AppColors.bgCard : null,
      gradient: gradient,
      borderRadius: AppSpacing.borderRadiusXl,
      boxShadow: widget.variant == StatCardVariant.hero
          ? AppShadows.lg
          : AppShadows.md,
    );
  }

  EdgeInsets _buildPadding() {
    switch (widget.size) {
      case StatCardSize.small:
        return AppSpacing.cardPaddingSmall;
      case StatCardSize.large:
        return AppSpacing.cardPaddingLarge;
      case StatCardSize.hero:
        return AppSpacing.cardPaddingHero;
      default:
        return AppSpacing.cardPaddingMedium;
    }
  }

  Widget _buildContent() {
    if (widget.variant == StatCardVariant.hero) {
      return _buildHeroContent();
    }
    return _buildDefaultContent();
  }

  Widget _buildHeroContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Center(child: widget.icon),
          ),
          const SizedBox(height: AppSpacing.space3),
        ],
        if (widget.title != null)
          Text(
            widget.title!.toUpperCase(),
            style: AppTypography.label(color: AppColors.textTertiary).copyWith(
              letterSpacing: 0.03,
            ),
          ),
        const SizedBox(height: AppSpacing.space1),
        ShaderMask(
          shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds),
          child: Text(
            widget.value,
            style: AppTypography.hero(color: Colors.white),
          ),
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: AppSpacing.space2),
          Text(
            widget.subtitle!,
            style: AppTypography.body(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
        if (widget.trend != null) ...[
          const SizedBox(height: AppSpacing.space3),
          _buildTrendBadge(),
        ],
      ],
    );
  }

  Widget _buildDefaultContent() {
    final iconSize = widget.size == StatCardSize.small ? 40.0 : 44.0;
    
    return Row(
      children: [
        if (widget.icon != null) ...[
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: _getIconBackgroundColor(),
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Center(child: widget.icon),
          ),
          SizedBox(width: widget.size == StatCardSize.small ? AppSpacing.space3 : AppSpacing.space4),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.title != null)
                Text(
                  widget.title!.toUpperCase(),
                  style: AppTypography.label(color: AppColors.textTertiary).copyWith(
                    fontSize: widget.size == StatCardSize.small ? 11 : 12,
                    letterSpacing: 0.03,
                  ),
                ),
              const SizedBox(height: 2),
              Text(
                widget.value,
                style: widget.size == StatCardSize.small
                    ? AppTypography.statValueSmall(color: _getValueColor())
                    : AppTypography.statValue(color: _getValueColor()),
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  widget.subtitle!,
                  style: AppTypography.caption(color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ],
          ),
        ),
        if (widget.trend != null) _buildTrendBadge(),
      ],
    );
  }

  Color _getIconBackgroundColor() {
    switch (widget.variant) {
      case StatCardVariant.accent:
        return AppColors.accentSoft;
      case StatCardVariant.productive:
        return AppColors.productiveSoft;
      default:
        return AppColors.neutral;
    }
  }

  Color _getValueColor() {
    switch (widget.variant) {
      case StatCardVariant.accent:
        return AppColors.accent;
      case StatCardVariant.productive:
        return AppColors.productive;
      default:
        return AppColors.textPrimary;
    }
  }

  Widget _buildTrendBadge() {
    final isPositive = widget.variant == StatCardVariant.productive
        ? widget.trend == 'up'
        : widget.trend == 'down';
    
    final backgroundColor = isPositive ? AppColors.productiveSoft : AppColors.accentSoft;
    final textColor = isPositive ? AppColors.productive : AppColors.accent;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.trend == 'up'
              ? AppIcons.trendUp(size: 14, color: textColor)
              : AppIcons.trendDown(size: 14, color: textColor),
          if (widget.trendValue != null) ...[
            const SizedBox(width: 4),
            Text(
              widget.trendValue!,
              style: AppTypography.caption(color: textColor).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}




