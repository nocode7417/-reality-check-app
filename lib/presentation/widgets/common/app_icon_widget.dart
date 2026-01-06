import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../data/models/models.dart';
import '../../providers/usage_providers.dart';

/// Widget for displaying app icons with caching and fallback
class AppIconWidget extends ConsumerWidget {
  final String packageName;
  final double size;
  final String? fallbackEmoji;
  final String? category;
  final BorderRadius? borderRadius;

  const AppIconWidget({
    super.key,
    required this.packageName,
    this.size = 40,
    this.fallbackEmoji,
    this.category,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconAsync = ref.watch(appIconProvider(packageName));

    return iconAsync.when(
      data: (iconBytes) {
        if (iconBytes != null) {
          return _buildIconContainer(
            child: ClipRRect(
              borderRadius: borderRadius ?? BorderRadius.circular(size * 0.2),
              child: Image.memory(
                iconBytes,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFallback(),
              ),
            ),
          );
        }
        return _buildFallback();
      },
      loading: _buildShimmer,
      error: (_, __) => _buildFallback(),
    );
  }

  Widget _buildIconContainer({required Widget child}) {
    return SizedBox(
      width: size,
      height: size,
      child: child,
    );
  }

  Widget _buildFallback() {
    final emoji = fallbackEmoji ?? _getDefaultEmoji();
    final bgColor = _getCategoryColor();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(size * 0.2),
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: borderRadius ?? BorderRadius.circular(size * 0.2),
      ),
      child: _ShimmerEffect(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius ?? BorderRadius.circular(size * 0.2),
          ),
        ),
      ),
    );
  }

  String _getDefaultEmoji() {
    final cat = category ?? AppPackages.getCategory(packageName);
    return AppPackages.getCategoryIcon(cat ?? 'Other');
  }

  Color _getCategoryColor() {
    final cat = category ?? AppPackages.getCategory(packageName);
    final colorHex = AppPackages.getCategoryColor(cat ?? 'Other');
    return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
  }
}

/// Cached app icon widget with pre-loaded icon bytes
class CachedAppIcon extends StatelessWidget {
  final Uint8List? iconBytes;
  final double size;
  final String? fallbackEmoji;
  final String? category;
  final BorderRadius? borderRadius;

  const CachedAppIcon({
    super.key,
    this.iconBytes,
    this.size = 40,
    this.fallbackEmoji,
    this.category,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (iconBytes != null) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(size * 0.2),
        child: Image.memory(
          iconBytes!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(),
        ),
      );
    }
    return _buildFallback();
  }

  Widget _buildFallback() {
    final emoji = fallbackEmoji ?? AppPackages.getCategoryIcon(category ?? 'Other');
    final colorHex = AppPackages.getCategoryColor(category ?? 'Other');
    final bgColor = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(size * 0.2),
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }
}

/// Simple emoji icon fallback for manual logging
class EmojiIcon extends StatelessWidget {
  final String emoji;
  final double size;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const EmojiIcon({
    super.key,
    required this.emoji,
    this.size = 40,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.bgTertiary,
        borderRadius: borderRadius ?? BorderRadius.circular(size * 0.2),
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }
}

/// Shimmer effect widget
class _ShimmerEffect extends StatefulWidget {
  final Widget child;

  const _ShimmerEffect({required this.child});

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFEEEEEE),
                Color(0xFFF5F5F5),
                Color(0xFFEEEEEE),
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// App usage list tile with icon, name, and usage time
class AppUsageListTile extends ConsumerWidget {
  final String packageName;
  final String appName;
  final String formattedTime;
  final String category;
  final bool isProductive;
  final VoidCallback? onTap;

  const AppUsageListTile({
    super.key,
    required this.packageName,
    required this.appName,
    required this.formattedTime,
    required this.category,
    required this.isProductive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space3),
        child: Row(
          children: [
            AppIconWidget(
              packageName: packageName,
              size: 44,
              category: category,
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appName,
                    style: AppTypography.body(color: AppColors.textPrimary)
                        .copyWith(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    category,
                    style: AppTypography.caption(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formattedTime,
                  style: AppTypography.body(
                    color: isProductive ? AppColors.productive : AppColors.accent,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isProductive
                        ? AppColors.productiveSoft
                        : AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isProductive ? 'Productive' : 'Wasted',
                    style: AppTypography.label(
                      color: isProductive ? AppColors.productive : AppColors.accent,
                    ).copyWith(fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
