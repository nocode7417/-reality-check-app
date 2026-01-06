import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../data/models/tracking_settings_model.dart';
import '../../providers/app_providers.dart';
import '../../providers/usage_providers.dart';

/// Permission screen for requesting usage access
class PermissionScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;

  const PermissionScreen({
    super.key,
    this.onComplete,
    this.onSkip,
  });

  @override
  ConsumerState<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends ConsumerState<PermissionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    setState(() => _isRequesting = true);

    final permissionNotifier = ref.read(usagePermissionProvider.notifier);
    await permissionNotifier.requestPermission();

    // Mark permission screen as seen
    final trackingNotifier = ref.read(trackingSettingsProvider.notifier);
    await trackingNotifier.markPermissionScreenSeen();

    setState(() => _isRequesting = false);

    // Show a snackbar telling user to come back after enabling
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enable "Usage Access" for Reality Check in Settings'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Got it',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  void _skip() {
    // Mark permission screen as seen
    ref.read(trackingSettingsProvider.notifier).markPermissionScreenSeen();
    widget.onSkip?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isAndroid = Platform.isAndroid;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space6),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Icon
              _buildAnimatedSection(
                index: 0,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '📊',
                      style: TextStyle(fontSize: 48),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.space8),

              // Title
              _buildAnimatedSection(
                index: 1,
                child: Text(
                  isAndroid
                      ? 'Track Your Real Usage'
                      : 'Manual Tracking Mode',
                  style: AppTypography.title(),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppSpacing.space4),

              // Description
              _buildAnimatedSection(
                index: 2,
                child: Text(
                  isAndroid
                      ? 'Enable usage access to automatically track which apps you spend time on. Your data stays private and never leaves your device.'
                      : 'iOS restricts app usage tracking. You\'ll manually log your activities, which is still effective for building awareness.',
                  style: AppTypography.body(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppSpacing.space8),

              // Features list
              _buildAnimatedSection(
                index: 3,
                child: Column(
                  children: isAndroid
                      ? [
                          _FeatureItem(
                            icon: '🔒',
                            title: 'Private & Secure',
                            description: 'Data stays on your device only',
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          _FeatureItem(
                            icon: '🔋',
                            title: 'Battery Efficient',
                            description: 'Minimal impact on battery life',
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          _FeatureItem(
                            icon: '📱',
                            title: 'Auto Detection',
                            description: 'Tracks TikTok, Instagram, games & more',
                          ),
                        ]
                      : [
                          _FeatureItem(
                            icon: '✏️',
                            title: 'Quick Logging',
                            description: 'Log activities in just a few taps',
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          _FeatureItem(
                            icon: '📈',
                            title: 'Track Progress',
                            description: 'See your habits and patterns',
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          _FeatureItem(
                            icon: '🎯',
                            title: 'Stay Accountable',
                            description: 'Build awareness of your time',
                          ),
                        ],
                ),
              ),

              const Spacer(flex: 2),

              // Buttons
              _buildAnimatedSection(
                index: 4,
                child: Column(
                  children: [
                    if (isAndroid) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isRequesting ? null : _requestPermission,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isRequesting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  'Enable Usage Access',
                                  style: AppTypography.button(color: Colors.white),
                                ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space4),
                    ],
                    TextButton(
                      onPressed: _skip,
                      child: Text(
                        isAndroid ? 'Skip for now' : 'Continue',
                        style: AppTypography.body(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.space4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSection({required int index, required Widget child}) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animController,
        curve: Interval(
          0.1 * index,
          0.1 * index + 0.4,
          curve: Curves.easeOut,
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animController,
          curve: Interval(
            0.1 * index,
            0.1 * index + 0.4,
            curve: Curves.easeOut,
          ),
        )),
        child: child,
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body(color: AppColors.textPrimary)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: AppTypography.caption(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Permission banner widget for showing in other screens
class PermissionBanner extends ConsumerWidget {
  final VoidCallback? onRequestPermission;

  const PermissionBanner({super.key, this.onRequestPermission});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAndroid = Platform.isAndroid;
    final permissionState = ref.watch(usagePermissionProvider);

    // Don't show if not Android or already granted
    if (!isAndroid || permissionState.isGranted) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.space4),
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withOpacity(0.1),
            AppColors.accent.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('📊', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Auto-Tracking',
                  style: AppTypography.body(color: AppColors.textPrimary)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Track app usage automatically',
                  style: AppTypography.caption(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              if (onRequestPermission != null) {
                onRequestPermission!();
              } else {
                ref.read(usagePermissionProvider.notifier).requestPermission();
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(
              'Enable',
              style: AppTypography.body(color: AppColors.accent)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// iOS mode banner explaining manual tracking
class IOSModeBanner extends StatelessWidget {
  const IOSModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.space4),
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text('', style: TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Text(
              'iOS uses manual logging for privacy. Tap below to log your activities!',
              style: AppTypography.caption(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
