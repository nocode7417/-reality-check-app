import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../data/models/tracking_settings_model.dart';
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

    // Show troubleshoot dialog for Android 13+ restricted settings
    if (mounted) {
      _showRestrictedSettingsHelp();
    }
  }

  void _showRestrictedSettingsHelp() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _RestrictedSettingsSheet(
        onOpenAppSettings: () {
          Navigator.pop(context);
          ref.read(platformChannelServiceProvider).openAppSettings();
        },
        onOpenUsageSettings: () {
          Navigator.pop(context);
          ref.read(platformChannelServiceProvider).openUsageAccessSettings();
        },
      ),
    );
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
                          const _FeatureItem(
                            icon: '🔒',
                            title: 'Private & Secure',
                            description: 'Data stays on your device only',
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          const _FeatureItem(
                            icon: '🔋',
                            title: 'Battery Efficient',
                            description: 'Minimal impact on battery life',
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          const _FeatureItem(
                            icon: '📱',
                            title: 'Auto Detection',
                            description: 'Tracks TikTok, Instagram, games & more',
                          ),
                        ]
                      : [
                          const _FeatureItem(
                            icon: '✏️',
                            title: 'Quick Logging',
                            description: 'Log activities in just a few taps',
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          const _FeatureItem(
                            icon: '📈',
                            title: 'Track Progress',
                            description: 'See your habits and patterns',
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          const _FeatureItem(
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

/// Bottom sheet for Android 13+ restricted settings help
class _RestrictedSettingsSheet extends StatelessWidget {
  final VoidCallback onOpenAppSettings;
  final VoidCallback onOpenUsageSettings;

  const _RestrictedSettingsSheet({
    required this.onOpenAppSettings,
    required this.onOpenUsageSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.space6,
        right: AppSpacing.space6,
        top: AppSpacing.space6,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.space6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space6),

          // Title
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('🔐', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: AppSpacing.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Permission Blocked?',
                      style: AppTypography.subheading(),
                    ),
                    Text(
                      'Android 13+ security feature',
                      style: AppTypography.caption(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.space6),

          // Explanation
          Container(
            padding: const EdgeInsets.all(AppSpacing.space4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.2)),
            ),
            child: Text(
              'If you see "App was denied access" or can\'t toggle Usage Access, your device has "Restricted Settings" enabled for sideloaded apps.',
              style: AppTypography.body(color: AppColors.textSecondary),
            ),
          ),

          const SizedBox(height: AppSpacing.space6),

          // Steps
          Text('Follow these steps:', style: AppTypography.sectionTitle()),
          const SizedBox(height: AppSpacing.space4),

          const _StepItem(
            number: '1',
            title: 'Open App Settings',
            description: 'Tap button below to go to Reality Check app info',
          ),
          const SizedBox(height: AppSpacing.space3),
          const _StepItem(
            number: '2',
            title: 'Find "Allow restricted settings"',
            description: 'Tap ⋮ menu (top right) → "Allow restricted settings"',
          ),
          const SizedBox(height: AppSpacing.space3),
          const _StepItem(
            number: '3',
            title: 'Enable Usage Access',
            description: 'Go back and enable Usage Access for Reality Check',
          ),

          const SizedBox(height: AppSpacing.space6),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onOpenAppSettings,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'App Settings',
                    style: AppTypography.button(color: AppColors.accent),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space4),
              Expanded(
                child: ElevatedButton(
                  onPressed: onOpenUsageSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Usage Access',
                    style: AppTypography.button(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.space4),

          // ADB hint for developers
          Center(
            child: TextButton(
              onPressed: () => _showAdbHelp(context),
              child: Text(
                'Developer? Use ADB command',
                style: AppTypography.caption(color: AppColors.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdbHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('ADB Command', style: AppTypography.subheading()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Run this command to grant permission directly:',
              style: AppTypography.body(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.space4),
            Container(
              padding: const EdgeInsets.all(AppSpacing.space3),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                'adb shell appops set com.realitycheck.reality_check GET_USAGE_STATS allow',
                style: AppTypography.caption(color: AppColors.accent)
                    .copyWith(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it', style: AppTypography.button(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _StepItem({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              number,
              style: AppTypography.caption(color: AppColors.accent)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.space3),
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
    );
  }
}
