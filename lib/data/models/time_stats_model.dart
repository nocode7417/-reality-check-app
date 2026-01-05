/// Time statistics for different periods
class TimeStatsModel {
  final PeriodStats today;
  final PeriodStats week;
  final PeriodStats month;
  final PeriodStats total;

  TimeStatsModel({
    required this.today,
    required this.week,
    required this.month,
    required this.total,
  });

  factory TimeStatsModel.empty() {
    return TimeStatsModel(
      today: PeriodStats.empty(),
      week: PeriodStats.empty(),
      month: PeriodStats.empty(),
      total: PeriodStats.empty(),
    );
  }

  factory TimeStatsModel.fromJson(Map<String, dynamic> json) {
    return TimeStatsModel(
      today: PeriodStats.fromJson(json['today'] as Map<String, dynamic>),
      week: PeriodStats.fromJson(json['week'] as Map<String, dynamic>),
      month: PeriodStats.fromJson(json['month'] as Map<String, dynamic>),
      total: PeriodStats.fromJson(json['total'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today': today.toJson(),
      'week': week.toJson(),
      'month': month.toJson(),
      'total': total.toJson(),
    };
  }
}

/// Stats for a single period
class PeriodStats {
  final double wasted;
  final double productive;
  
  PeriodStats({
    required this.wasted,
    required this.productive,
  });

  factory PeriodStats.empty() {
    return PeriodStats(wasted: 0, productive: 0);
  }

  factory PeriodStats.fromJson(Map<String, dynamic> json) {
    return PeriodStats(
      wasted: (json['wasted'] as num).toDouble(),
      productive: (json['productive'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wasted': wasted,
      'productive': productive,
    };
  }

  double get total => wasted + productive;
  
  double get wastedPercent => total > 0 ? (wasted / total) * 100 : 0;
  double get productivePercent => total > 0 ? (productive / total) * 100 : 0;
}

/// Daily totals for calendar heatmap
class DailyTotals {
  final Map<String, DayData> data;

  DailyTotals({required this.data});

  factory DailyTotals.empty() => DailyTotals(data: {});

  DayData? getDay(DateTime date) {
    final key = _dateKey(date);
    return data[key];
  }

  void setDay(DateTime date, DayData dayData) {
    final key = _dateKey(date);
    data[key] = dayData;
  }

  static String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Data for a single day
class DayData {
  final double wasted;
  final double productive;

  DayData({
    required this.wasted,
    required this.productive,
  });

  factory DayData.empty() => DayData(wasted: 0, productive: 0);

  double get total => wasted + productive;
  
  /// Get intensity for calendar coloring (0-1)
  double get intensity => total > 0 ? (wasted / 6).clamp(0.0, 1.0) : 0;
  
  bool get hasData => total > 0;
  bool get hasProductive => productive > 0;
}

/// Chart data point
class ChartDataPoint {
  final String label;
  final double wasted;
  final double productive;

  ChartDataPoint({
    required this.label,
    required this.wasted,
    required this.productive,
  });
}

/// Weekly comparison data
class WeeklyComparison {
  final double diff;
  final int percentChange;
  final bool improved;
  final String trend; // 'up', 'down', 'same'

  WeeklyComparison({
    required this.diff,
    required this.percentChange,
    required this.improved,
    required this.trend,
  });

  factory WeeklyComparison.calculate(double currentWeek, double previousWeek) {
    final diff = currentWeek - previousWeek;
    final percentChange = previousWeek > 0 
        ? ((diff / previousWeek) * 100).round().abs()
        : 0;

    return WeeklyComparison(
      diff: diff.abs(),
      percentChange: percentChange,
      improved: diff < 0,
      trend: diff < 0 ? 'down' : diff > 0 ? 'up' : 'same',
    );
  }
}




