import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../data/models/models.dart';
import '../../../data/services/services.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/app_icons.dart';
import 'dart:math' as math;

/// Calendar screen - visual heatmap of time usage
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(timeStatsProvider);
    final dailyTotals = ref.watch(dailyTotalsProvider);
    final currentMonth = ref.watch(currentMonthProvider);
    final selectedDay = ref.watch(selectedDayProvider);

    final wastedPercent = stats.week.total > 0
        ? (stats.week.wasted / stats.week.total * 100).round()
        : 0;
    final productivePercent = 100 - wastedPercent;

    return PageWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: AppSpacing.space6),

          // Progress Ring
          _buildProgressRing(productivePercent, stats),
          const SizedBox(height: AppSpacing.space6),

          // Calendar
          _TimeCalendar(
            currentMonth: currentMonth,
            dailyTotals: dailyTotals,
            selectedDay: selectedDay,
            onMonthChanged: (date) {
              ref.read(currentMonthProvider.notifier).state = date;
            },
            onDaySelected: (date) {
              ref.read(selectedDayProvider.notifier).state = date;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return _AnimatedFadeIn(
      delay: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calendar',
            style: AppTypography.title(),
          ),
          const SizedBox(height: 2),
          Text(
            'Your time at a glance',
            style: AppTypography.body(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRing(int productivePercent, TimeStatsModel stats) {
    return _AnimatedFadeIn(
      delay: 1,
      child: Row(
        children: [
          // Progress Ring
          SizedBox(
            width: 100,
            height: 100,
            child: _ProgressRing(percent: productivePercent),
          ),
          const SizedBox(width: AppSpacing.space6),
          // Stats
          Expanded(
            child: Column(
              children: [
                _WeekStat(
                  value: CalculationService.formatHours(stats.week.wasted),
                  label: 'wasted',
                  color: AppColors.accent,
                ),
                const SizedBox(height: AppSpacing.space4),
                _WeekStat(
                  value: CalculationService.formatHours(stats.week.productive),
                  label: 'productive',
                  color: AppColors.productive,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatefulWidget {
  final int percent;

  const _ProgressRing({required this.percent});

  @override
  State<_ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<_ProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0, end: widget.percent / 100)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    Future.delayed(const Duration(milliseconds: 200), () {
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: _animation.value,
                  backgroundColor: AppColors.neutral,
                  progressColor: AppColors.productive,
                  strokeWidth: 8,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(_animation.value * 100).round()}%',
                  style: AppTypography.heading(color: AppColors.textPrimary),
                ),
                Text(
                  'productive',
                  style: AppTypography.label(color: AppColors.textTertiary),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _WeekStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _WeekStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          value,
          style: AppTypography.statValueSmall(color: color),
        ),
        const SizedBox(width: AppSpacing.space2),
        Text(
          label,
          style: AppTypography.caption(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _TimeCalendar extends StatelessWidget {
  final DateTime currentMonth;
  final DailyTotals dailyTotals;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDaySelected;

  const _TimeCalendar({
    required this.currentMonth,
    required this.dailyTotals,
    required this.selectedDay,
    required this.onMonthChanged,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final year = currentMonth.year;
    final month = currentMonth.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDayOfMonth = DateTime(year, month, 1).weekday % 7;
    final monthName = _getMonthName(month);

    return _AnimatedFadeIn(
      delay: 2,
      child: Container(
        padding: AppSpacing.cardPaddingMedium,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: AppSpacing.borderRadiusXl,
          boxShadow: AppShadows.md,
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(monthName, year),
            const SizedBox(height: AppSpacing.space5),

            // Day labels
            _buildDayLabels(),
            const SizedBox(height: AppSpacing.space2),

            // Calendar grid
            _buildGrid(context, daysInMonth, firstDayOfMonth, year, month),

            // Legend
            const SizedBox(height: AppSpacing.space4),
            const Divider(color: AppColors.borderLight),
            const SizedBox(height: AppSpacing.space4),
            _buildLegend(),

            // Selected day details
            if (selectedDay != null) _buildSelectedDayDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String monthName, int year) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _NavButton(
          icon: AppIcons.chevronLeft(size: 20),
          onTap: () {
            onMonthChanged(DateTime(currentMonth.year, currentMonth.month - 1));
          },
        ),
        Column(
          children: [
            Text(
              monthName,
              style: AppTypography.sectionTitle(),
            ),
            Text(
              '$year',
              style: AppTypography.caption(color: AppColors.textTertiary),
            ),
          ],
        ),
        _NavButton(
          icon: AppIcons.chevronRight(size: 20),
          onTap: () {
            onMonthChanged(DateTime(currentMonth.year, currentMonth.month + 1));
          },
        ),
      ],
    );
  }

  Widget _buildDayLabels() {
    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      children: labels.map((label) {
        return Expanded(
          child: Center(
            child: Text(
              label,
              style: AppTypography.label(color: AppColors.textTertiary).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGrid(BuildContext context, int daysInMonth, int firstDay, int year, int month) {
    final today = DateTime.now();
    final widgets = <Widget>[];

    // Empty cells
    for (var i = 0; i < firstDay; i++) {
      widgets.add(const SizedBox());
    }

    // Day cells
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final isToday = date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final isFuture = date.isAfter(today);
      final isSelected = selectedDay != null &&
          selectedDay!.year == date.year &&
          selectedDay!.month == date.month &&
          selectedDay!.day == date.day;

      final dayData = dailyTotals.getDay(date);
      final intensity = dayData?.intensity ?? 0;
      final hasProductive = dayData?.hasProductive ?? false;

      widgets.add(
        _DayCell(
          day: day,
          isToday: isToday,
          isFuture: isFuture,
          isSelected: isSelected,
          intensity: intensity,
          hasProductive: hasProductive,
          onTap: isFuture ? null : () => onDaySelected(date),
        ),
      );
    }

    // Responsive aspect ratio for tablets
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      childAspectRatio: isTablet ? 1.5 : 1.0,
      children: widgets,
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Less',
          style: AppTypography.label(color: AppColors.textMuted),
        ),
        const SizedBox(width: AppSpacing.space2),
        _LegendSwatch(color: AppColors.intensityNone),
        _LegendSwatch(color: AppColors.intensityLow),
        _LegendSwatch(color: AppColors.intensityMedium),
        _LegendSwatch(color: AppColors.intensityExtreme),
        const SizedBox(width: AppSpacing.space2),
        Text(
          'More',
          style: AppTypography.label(color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildSelectedDayDetails() {
    final dayData = dailyTotals.getDay(selectedDay!);
    if (dayData == null || !dayData.hasData) return const SizedBox();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(top: AppSpacing.space4),
      padding: AppSpacing.cardPaddingSmall,
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: AppSpacing.borderRadiusLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_getMonthName(selectedDay!.month)} ${selectedDay!.day}',
            style: AppTypography.caption(color: AppColors.textPrimary).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          Row(
            children: [
              Text(
                CalculationService.formatHours(dayData.wasted),
                style: AppTypography.statValueSmall(color: AppColors.accent),
              ),
              const SizedBox(width: AppSpacing.space2),
              Text('wasted', style: AppTypography.caption()),
              const SizedBox(width: AppSpacing.space6),
              Text(
                CalculationService.formatHours(dayData.productive),
                style: AppTypography.statValueSmall(color: AppColors.productive),
              ),
              const SizedBox(width: AppSpacing.space2),
              Text('productive', style: AppTypography.caption()),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }
}

class _NavButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
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
        width: 36,
        height: 36,
        transform: Matrix4.identity()..scale(_isPressed ? 0.9 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isPressed ? AppColors.neutralLight : AppColors.neutral,
          borderRadius: AppSpacing.borderRadiusFull,
        ),
        child: Center(child: widget.icon),
      ),
    );
  }
}

class _DayCell extends StatefulWidget {
  final int day;
  final bool isToday;
  final bool isFuture;
  final bool isSelected;
  final double intensity;
  final bool hasProductive;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isFuture,
    required this.isSelected,
    required this.intensity,
    required this.hasProductive,
    this.onTap,
  });

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.intensity > 0
        ? AppColors.getIntensityColor(widget.intensity)
        : AppColors.neutral;

    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..scale(widget.isSelected ? 1.1 : (_isPressed ? 0.95 : 1.0)),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.isFuture ? AppColors.neutral.withOpacity(0.35) : backgroundColor,
          borderRadius: AppSpacing.borderRadiusMd,
          border: widget.isToday
              ? Border.all(color: AppColors.accent, width: 2)
              : null,
          boxShadow: widget.isSelected ? AppShadows.selectedDay : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${widget.day}',
              style: AppTypography.body(
                color: widget.isFuture
                    ? AppColors.textMuted
                    : (widget.intensity > 0.5 ? Colors.white : AppColors.textPrimary),
              ).copyWith(
                fontWeight: widget.isToday ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (widget.hasProductive && !widget.isFuture)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.productive,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LegendSwatch extends StatelessWidget {
  final Color color;

  const _LegendSwatch({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _AnimatedFadeIn extends StatefulWidget {
  final Widget child;
  final int delay;

  const _AnimatedFadeIn({
    required this.child,
    required this.delay,
  });

  @override
  State<_AnimatedFadeIn> createState() => _AnimatedFadeInState();
}

class _AnimatedFadeInState extends State<_AnimatedFadeIn>
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

    Future.delayed(Duration(milliseconds: 50 * widget.delay), () {
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




