import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/theme.dart';
import '../../../data/services/services.dart';
import '../../../data/models/time_stats_model.dart';
import '../../../data/models/tracking_settings_model.dart';
import '../../providers/app_providers.dart';
import '../../providers/usage_providers.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/common/app_icons.dart';
import '../../widgets/common/app_icon_widget.dart';
import '../permissions/permission_screen.dart';

/// Dashboard screen - main landing page showing weekly stats
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

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

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(timeStatsProvider);
    final realityMessage = ref.watch(realityCheckMessageProvider);
    final weekComparison = ref.watch(weeklyComparisonProvider);
    final potentialEarnings = ref.watch(potentialEarningsProvider);
    final learningDays = ref.watch(learningDaysProvider);
    final chartData = ref.watch(weeklyChartDataProvider);
    final topApps = ref.watch(topAppsTodayProvider);
    final permissionState = ref.watch(usagePermissionProvider);
    final isAndroid = Platform.isAndroid;

    return PageWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: AppSpacing.space6),

          // Permission banner (Android only, if not granted)
          if (isAndroid && !permissionState.isGranted)
            PermissionBanner(
              onRequestPermission: () {
                ref.read(usagePermissionProvider.notifier).requestPermission();
              },
            ),

          // Hero Stat Card
          StatCard(
            variant: StatCardVariant.hero,
            icon: AppIcons.clock(size: 28, color: AppColors.accent),
            title: 'Time Wasted',
            value: CalculationService.formatHours(stats.week.wasted),
            subtitle: realityMessage,
            trend: weekComparison.trend,
            trendValue: '${weekComparison.percentChange}%',
            staggerIndex: 1,
          ),
          const SizedBox(height: AppSpacing.space6),

          // Comparison Cards
          _buildComparisonSection(potentialEarnings, learningDays),
          const SizedBox(height: AppSpacing.space6),

          // Top Apps Today (only show if we have native tracking data)
          if (topApps.isNotEmpty) ...[
            _buildTopAppsSection(topApps),
            const SizedBox(height: AppSpacing.space6),
          ],

          // Weekly Chart
          _buildChartSection(chartData),
          const SizedBox(height: AppSpacing.space6),

          // Today Stats
          _buildTodaySection(stats),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _animController, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut)),
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.space2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reality Check',
                style: AppTypography.eyebrow(),
              ),
              const SizedBox(height: 2),
              Text(
                'Your Week',
                style: AppTypography.title(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonSection(int earnings, int days) {
    return Row(
      children: [
        Expanded(
          child: _ComparisonCard(
            icon: AppIcons.dollar(size: 20, color: AppColors.accent),
            iconBackground: AppColors.accentSoft,
            value: '\$$earnings',
            valueColor: AppColors.accent,
            label: 'could have earned',
            staggerIndex: 2,
          ),
        ),
        const SizedBox(width: AppSpacing.space4),
        Expanded(
          child: _ComparisonCard(
            icon: AppIcons.book(size: 20, color: AppColors.productive),
            iconBackground: AppColors.productiveSoft,
            value: '$days days',
            valueColor: AppColors.productive,
            label: 'of skill practice',
            staggerIndex: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection(List<ChartDataPoint> data) {
    return _AnimatedSection(
      staggerIndex: 4,
      child: Container(
        padding: AppSpacing.cardPaddingMedium,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: AppSpacing.borderRadiusXl,
          boxShadow: AppShadows.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'This Week'),
            SizedBox(
              height: 140,
              child: data.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '📊',
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: AppSpacing.space2),
                          Text(
                            'No data yet',
                            style: AppTypography.caption(color: AppColors.textMuted),
                          ),
                          Text(
                            'Start logging activities!',
                            style: AppTypography.label(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    )
                  : Semantics(
                      label: 'Weekly time usage chart showing ${data.length} days of data',
                      child: _WeeklyChart(data: data),
                    ),
            ),
            const SizedBox(height: AppSpacing.space4),
            const Divider(color: AppColors.borderLight),
            const SizedBox(height: AppSpacing.space4),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: AppColors.accent, label: 'Wasted'),
        const SizedBox(width: AppSpacing.space6),
        _LegendItem(color: AppColors.productive, label: 'Productive'),
      ],
    );
  }

  Widget _buildTodaySection(TimeStatsModel stats) {
    return _AnimatedSection(
      staggerIndex: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Today'),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  variant: StatCardVariant.accent,
                  size: StatCardSize.small,
                  icon: const Text('📱', style: TextStyle(fontSize: 18)),
                  title: 'Wasted',
                  value: CalculationService.formatHours(stats.today.wasted),
                  staggerIndex: 6,
                ),
              ),
              const SizedBox(width: AppSpacing.space4),
              Expanded(
                child: StatCard(
                  variant: StatCardVariant.productive,
                  size: StatCardSize.small,
                  icon: const Text('✓', style: TextStyle(fontSize: 18)),
                  title: 'Productive',
                  value: CalculationService.formatHours(stats.today.productive),
                  staggerIndex: 7,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppsSection(List<NativeAppUsage> topApps) {
    return _AnimatedSection(
      staggerIndex: 4,
      child: Container(
        padding: AppSpacing.cardPaddingMedium,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: AppSpacing.borderRadiusXl,
          boxShadow: AppShadows.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionHeader(title: 'Top Apps Today'),
                _SyncIndicator(),
              ],
            ),
            const SizedBox(height: AppSpacing.space2),
            ...topApps.map((app) => _TopAppTile(app: app)),
          ],
        ),
      ),
    );
  }
}

// ============ HELPER WIDGETS ============

class _ComparisonCard extends StatefulWidget {
  final Widget icon;
  final Color iconBackground;
  final String value;
  final Color valueColor;
  final String label;
  final int staggerIndex;

  const _ComparisonCard({
    required this.icon,
    required this.iconBackground,
    required this.value,
    required this.valueColor,
    required this.label,
    required this.staggerIndex,
  });

  @override
  State<_ComparisonCard> createState() => _ComparisonCardState();
}

class _ComparisonCardState extends State<_ComparisonCard>
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
      begin: const Offset(0, 0.1),
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
        child: Container(
          padding: AppSpacing.cardPaddingSmall,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: AppSpacing.borderRadiusLg,
            boxShadow: AppShadows.md,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.iconBackground,
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                child: Center(child: widget.icon),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.value,
                      style: AppTypography.comparisonValue(color: widget.valueColor),
                    ),
                    Text(
                      widget.label,
                      style: AppTypography.label(color: AppColors.textTertiary),
                    ),
                  ],
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

class _WeeklyChart extends StatelessWidget {
  final List<ChartDataPoint> data;

  const _WeeklyChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    data[index].label,
                    style: AppTypography.label(color: AppColors.textTertiary),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          // Wasted line
          LineChartBarData(
            spots: data.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.wasted);
            }).toList(),
            isCurved: true,
            color: AppColors.accent,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.accent.withOpacity(0.2),
                  AppColors.accent.withOpacity(0),
                ],
              ),
            ),
          ),
          // Productive line
          LineChartBarData(
            spots: data.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.productive);
            }).toList(),
            isCurved: true,
            color: AppColors.productive,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.productive.withOpacity(0.2),
                  AppColors.productive.withOpacity(0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final isWasted = spot.barIndex == 0;
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)}h',
                  AppTypography.caption(
                    color: isWasted ? AppColors.accent : AppColors.productive,
                  ).copyWith(fontWeight: FontWeight.w600),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
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

class _TopAppTile extends StatelessWidget {
  final NativeAppUsage app;

  const _TopAppTile({required this.app});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
      child: Row(
        children: [
          AppIconWidget(
            packageName: app.packageName,
            size: 40,
            category: app.category,
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.appName,
                  style: AppTypography.body(color: AppColors.textPrimary)
                      .copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  app.category,
                  style: AppTypography.caption(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            app.formattedTime,
            style: AppTypography.body(
              color: app.isProductive ? AppColors.productive : AppColors.accent,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SyncIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastSync = ref.watch(lastSyncTimeProvider);

    String syncText = 'Never';
    if (lastSync != null) {
      final elapsed = DateTime.now().difference(lastSync);
      if (elapsed.inMinutes < 1) {
        syncText = 'Just now';
      } else if (elapsed.inMinutes < 60) {
        syncText = '${elapsed.inMinutes}m ago';
      } else {
        syncText = '${elapsed.inHours}h ago';
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.productive,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          syncText,
          style: AppTypography.label(color: AppColors.textTertiary),
        ),
      ],
    );
  }
}




