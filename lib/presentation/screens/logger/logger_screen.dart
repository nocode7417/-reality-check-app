import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../data/models/models.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/app_icons.dart';

/// Logger screen - log time spent on activities
class LoggerScreen extends ConsumerStatefulWidget {
  const LoggerScreen({super.key});

  @override
  ConsumerState<LoggerScreen> createState() => _LoggerScreenState();
}

class _LoggerScreenState extends ConsumerState<LoggerScreen> {
  bool _showSuccess = false;
  ActivityModel? _lastLogged;

  @override
  Widget build(BuildContext context) {
    final selectedApp = ref.watch(selectedAppProvider);
    final selectedDuration = ref.watch(selectedDurationProvider);
    final isLogging = ref.watch(isLoadingProvider);

    return Stack(
      children: [
        PageWrapper(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: AppSpacing.space6),

              // App Selection
              _buildAppSelection(selectedApp),
              const SizedBox(height: AppSpacing.space6),

              // Duration Selection
              _buildDurationSelection(selectedDuration),
              const SizedBox(height: AppSpacing.space6),

              // Preview
              if (selectedApp != null)
                _buildPreview(selectedApp, selectedDuration),
              if (selectedApp != null) const SizedBox(height: AppSpacing.space6),

              // Submit Button
              _buildSubmitButton(selectedApp, selectedDuration, isLogging),
            ],
          ),
        ),

        // Success Toast
        if (_showSuccess && _lastLogged != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 0,
            right: 0,
            child: Center(
              child: _SuccessToast(
                message: 'Logged ${_lastLogged!.duration}m of ${_lastLogged!.app}',
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return _AnimatedSection(
      staggerIndex: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Log Activity',
            style: AppTypography.title(),
          ),
          const SizedBox(height: 2),
          Text(
            'Where did your time go?',
            style: AppTypography.body(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSelection(AppInfo? selectedApp) {
    final quickApps = AppCategories.quickApps;

    return _AnimatedSection(
      staggerIndex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELECT APP',
            style: AppTypography.label(color: AppColors.textTertiary).copyWith(
              letterSpacing: 0.03,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          
          // Quick app grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 3,
              crossAxisSpacing: AppSpacing.space3,
              mainAxisSpacing: AppSpacing.space3,
              childAspectRatio: 1,
            ),
            itemCount: quickApps.length,
            itemBuilder: (context, index) {
              final app = quickApps[index];
              final isSelected = selectedApp?.name == app.name;
              
              return _AppCard(
                app: app,
                isSelected: isSelected,
                onTap: () {
                  ref.read(selectedAppProvider.notifier).state = app;
                },
                staggerIndex: index,
              );
            },
          ),
          const SizedBox(height: AppSpacing.space4),

          // More apps button
          _MoreAppsSection(
            selectedApp: selectedApp,
            onAppSelected: (app) {
              ref.read(selectedAppProvider.notifier).state = app;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSelection(int selectedDuration) {
    const presets = [15, 30, 60, 90, 120];

    return _AnimatedSection(
      staggerIndex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DURATION',
            style: AppTypography.label(color: AppColors.textTertiary).copyWith(
              letterSpacing: 0.03,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.space3),

          // Preset chips
          Row(
            children: presets.map((mins) {
              final isSelected = selectedDuration == mins;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: mins == presets.last ? 0 : AppSpacing.space2,
                  ),
                  child: _DurationChip(
                    duration: mins,
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(selectedDurationProvider.notifier).state = mins;
                    },
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.space4),

          // Slider
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    thumbShape: const _CustomThumbShape(),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                    activeTrackColor: AppColors.accent,
                    inactiveTrackColor: AppColors.neutralLight,
                    thumbColor: Colors.white,
                    overlayColor: AppColors.accentSoft,
                  ),
                  child: Semantics(
                    label: 'Duration slider: ${_formatDuration(selectedDuration)}',
                    slider: true,
                    child: Slider(
                      value: selectedDuration.toDouble(),
                      min: 5,
                      max: 180,
                      divisions: 35,
                      onChanged: (value) {
                        ref.read(selectedDurationProvider.notifier).state = value.round();
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space4),
              SizedBox(
                width: 50,
                child: Text(
                  _formatDuration(selectedDuration),
                  style: AppTypography.sectionTitle(color: AppColors.accent),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(AppInfo app, int duration) {
    return _AnimatedSection(
      staggerIndex: 3,
      child: Container(
        padding: AppSpacing.cardPaddingSmall,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: AppSpacing.borderRadiusLg,
          boxShadow: AppShadows.md,
          border: Border(
            left: BorderSide(
              color: app.isProductive ? AppColors.productive : AppColors.accent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(app.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.name,
                    style: AppTypography.sectionTitle(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    '${app.category} · ${_formatDuration(duration)}',
                    style: AppTypography.caption(color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            _ClearButton(
              onTap: () {
                ref.read(selectedAppProvider.notifier).state = null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AppInfo? app, int duration, bool isLoading) {
    return _AnimatedSection(
      staggerIndex: 4,
      child: _SubmitButton(
        enabled: app != null && !isLoading,
        isLoading: isLoading,
        onTap: () async {
          if (app == null) return;

          ref.read(isLoadingProvider.notifier).state = true;

          // Simulate network delay for UX
          await Future.delayed(const Duration(milliseconds: 400));

          final activity = await ref.read(activitiesProvider.notifier).addActivity(
            app: app,
            duration: duration,
          );

          ref.read(isLoadingProvider.notifier).state = false;
          ref.read(selectedAppProvider.notifier).state = null;
          ref.read(selectedDurationProvider.notifier).state = 30;

          setState(() {
            _lastLogged = activity;
            _showSuccess = true;
          });

          // Hide toast after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() => _showSuccess = false);
            }
          });
        },
      ),
    );
  }

  String _formatDuration(int mins) {
    if (mins < 60) return '${mins}m';
    final hours = mins ~/ 60;
    final remaining = mins % 60;
    return remaining > 0 ? '${hours}h ${remaining}m' : '${hours}h';
  }
}

// ============ HELPER WIDGETS ============

class _AppCard extends StatefulWidget {
  final AppInfo app;
  final bool isSelected;
  final VoidCallback onTap;
  final int staggerIndex;

  const _AppCard({
    required this.app,
    required this.isSelected,
    required this.onTap,
    required this.staggerIndex,
  });

  @override
  State<_AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<_AppCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: widget.isSelected ? AppColors.accentGradient : null,
          color: widget.isSelected ? null : AppColors.bgCard,
          borderRadius: AppSpacing.borderRadiusLg,
          boxShadow: widget.isSelected
              ? [...AppShadows.lg, ...AppShadows.glow]
              : AppShadows.md,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.app.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Text(
                    widget.app.name,
                    style: AppTypography.label(
                      color: widget.isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            if (widget.isSelected)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: AppIcons.check(size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MoreAppsSection extends StatefulWidget {
  final AppInfo? selectedApp;
  final ValueChanged<AppInfo> onAppSelected;

  const _MoreAppsSection({
    required this.selectedApp,
    required this.onAppSelected,
  });

  @override
  State<_MoreAppsSection> createState() => _MoreAppsSectionState();
}

class _MoreAppsSectionState extends State<_MoreAppsSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Text(
            '${_isExpanded ? '- ' : '+ '}More apps',
            style: AppTypography.caption(color: AppColors.accent).copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: AppSpacing.space4),
          ...AppCategories.all.map((category) => _CategoryGroup(
            category: category,
            selectedApp: widget.selectedApp,
            onAppSelected: widget.onAppSelected,
          )),
        ],
      ],
    );
  }
}

class _CategoryGroup extends StatelessWidget {
  final AppCategory category;
  final AppInfo? selectedApp;
  final ValueChanged<AppInfo> onAppSelected;

  const _CategoryGroup({
    required this.category,
    required this.selectedApp,
    required this.onAppSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.name.toUpperCase(),
            style: AppTypography.label(color: AppColors.textMuted).copyWith(
              letterSpacing: 0.03,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: category.apps.map((app) {
              final appInfo = AppInfo(
                name: app.name,
                icon: app.icon,
                color: app.color,
                category: category.name,
                isProductive: category.isProductive,
              );
              final isSelected = selectedApp?.name == app.name;

              return _AppChip(
                app: appInfo,
                isSelected: isSelected,
                onTap: () => onAppSelected(appInfo),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AppChip extends StatefulWidget {
  final AppInfo app;
  final bool isSelected;
  final VoidCallback onTap;

  const _AppChip({
    required this.app,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AppChip> createState() => _AppChipState();
}

class _AppChipState extends State<_AppChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space2,
        ),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.isSelected ? AppColors.accent : AppColors.neutral,
          borderRadius: AppSpacing.borderRadiusFull,
        ),
        child: Text(
          '${widget.app.icon} ${widget.app.name}',
          style: AppTypography.caption(
            color: widget.isSelected ? Colors.white : AppColors.textSecondary,
          ).copyWith(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _DurationChip extends StatefulWidget {
  final int duration;
  final bool isSelected;
  final VoidCallback onTap;

  const _DurationChip({
    required this.duration,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_DurationChip> createState() => _DurationChipState();
}

class _DurationChipState extends State<_DurationChip> {
  bool _isPressed = false;

  String _formatDuration(int mins) {
    if (mins < 60) return '${mins}m';
    final hours = mins ~/ 60;
    final remaining = mins % 60;
    return remaining > 0 ? '${hours}h ${remaining}m' : '${hours}h';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.isSelected ? AppColors.accent : AppColors.bgCard,
          borderRadius: AppSpacing.borderRadiusMd,
          boxShadow: widget.isSelected
              ? [...AppShadows.md, ...AppShadows.glow]
              : AppShadows.sm,
        ),
        child: Center(
          child: Text(
            _formatDuration(widget.duration),
            style: AppTypography.caption(
              color: widget.isSelected ? Colors.white : AppColors.textSecondary,
            ).copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

class _ClearButton extends StatefulWidget {
  final VoidCallback onTap;

  const _ClearButton({required this.onTap});

  @override
  State<_ClearButton> createState() => _ClearButtonState();
}

class _ClearButtonState extends State<_ClearButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 32,
        height: 32,
        transform: Matrix4.identity()..scale(_isPressed ? 0.9 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isPressed ? AppColors.accent : AppColors.neutral,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: AppIcons.x(
            size: 16,
            color: _isPressed ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatefulWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.enabled,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.enabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
        transform: Matrix4.identity()
          ..scale(_isPressed ? 0.98 : 1.0)
          ..translate(0.0, _isPressed ? 0.0 : -2.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: AppSpacing.borderRadiusLg,
          boxShadow: widget.enabled ? AppShadows.button : null,
        ),
        child: Opacity(
          opacity: widget.enabled ? 1.0 : 0.5,
          child: widget.isLoading
              ? const _LoadingDot()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppIcons.check(size: 20, color: Colors.white),
                    const SizedBox(width: AppSpacing.space2),
                    Text(
                      'Log Activity',
                      style: AppTypography.button(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _LoadingDot extends StatefulWidget {
  const _LoadingDot();

  @override
  State<_LoadingDot> createState() => _LoadingDotState();
}

class _LoadingDotState extends State<_LoadingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = Tween<double>(begin: 1, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start repeating animation
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.stop(); // Stop repeating before dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class _SuccessToast extends StatefulWidget {
  final String message;

  const _SuccessToast({required this.message});

  @override
  State<_SuccessToast> createState() => _SuccessToastState();
}

class _SuccessToastState extends State<_SuccessToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space3,
          ),
          decoration: BoxDecoration(
            color: AppColors.productive,
            borderRadius: AppSpacing.borderRadiusFull,
            boxShadow: AppShadows.lg,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppIcons.check(size: 14, color: Colors.white),
              ),
              const SizedBox(width: AppSpacing.space3),
              Text(
                widget.message,
                style: AppTypography.caption(color: Colors.white).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedSection extends StatefulWidget {
  final Widget child;
  final int staggerIndex;

  const _AnimatedSection({
    required this.child,
    required this.staggerIndex,
  });

  @override
  State<_AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<_AnimatedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
        child: widget.child,
      ),
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  const _CustomThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(24, 24);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Ring shadow
    final shadowPaint = Paint()
      ..color = AppColors.accent.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, 12, shadowPaint);

    // White thumb
    final thumbPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Drop shadow
    canvas.drawShadow(
      Path()..addOval(Rect.fromCircle(center: center, radius: 12)),
      Colors.black,
      4,
      true,
    );

    canvas.drawCircle(center, 12, thumbPaint);
  }
}




