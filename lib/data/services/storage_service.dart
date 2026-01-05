import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

/// Local storage service using Hive for offline-first architecture
class StorageService {
  static const String _activitiesBox = 'activities';
  static const String _settingsBox = 'settings';

  late Box<ActivityModel> _activitiesBoxInstance;
  late Box<dynamic> _settingsBoxInstance;
  
  final Uuid _uuid = const Uuid();

  /// Initialize Hive and register adapters
  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ActivityModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AppSettingsModelAdapter());
    }

    // Open boxes
    _activitiesBoxInstance = await Hive.openBox<ActivityModel>(_activitiesBox);
    _settingsBoxInstance = await Hive.openBox(_settingsBox);
  }

  // ============ ACTIVITIES ============

  /// Get all activities
  List<ActivityModel> getActivities() {
    return _activitiesBoxInstance.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get activities for a date range
  List<ActivityModel> getActivitiesByDateRange(DateTime start, DateTime end) {
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
    
    return getActivities().where((activity) {
      return activity.date.isAfter(startDay.subtract(const Duration(seconds: 1))) &&
             activity.date.isBefore(endDay.add(const Duration(seconds: 1)));
    }).toList();
  }

  /// Get activities for a specific day
  List<ActivityModel> getActivitiesForDay(DateTime date) {
    return getActivitiesByDateRange(date, date);
  }

  /// Save a new activity
  Future<ActivityModel> saveActivity({
    required String app,
    required String appIcon,
    required String appColor,
    required String category,
    required int duration,
    required bool isProductive,
    DateTime? date,
  }) async {
    final now = DateTime.now();
    final activity = ActivityModel(
      id: _uuid.v4(),
      app: app,
      appIcon: appIcon,
      appColor: appColor,
      category: category,
      duration: duration,
      date: date ?? now,
      isProductive: isProductive,
      createdAt: now,
    );

    await _activitiesBoxInstance.put(activity.id, activity);
    return activity;
  }

  /// Update an activity
  Future<ActivityModel?> updateActivity(String id, Map<String, dynamic> updates) async {
    final activity = _activitiesBoxInstance.get(id);
    if (activity == null) return null;

    final updated = activity.copyWith(
      app: updates['app'] as String?,
      appIcon: updates['appIcon'] as String?,
      appColor: updates['appColor'] as String?,
      category: updates['category'] as String?,
      duration: updates['duration'] as int?,
      date: updates['date'] as DateTime?,
      isProductive: updates['isProductive'] as bool?,
      updatedAt: DateTime.now(),
    );

    await _activitiesBoxInstance.put(id, updated);
    return updated;
  }

  /// Delete an activity
  Future<void> deleteActivity(String id) async {
    await _activitiesBoxInstance.delete(id);
  }

  /// Clear all activities
  Future<void> clearActivities() async {
    await _activitiesBoxInstance.clear();
  }

  // ============ SETTINGS ============

  /// Get settings
  AppSettingsModel getSettings() {
    final json = _settingsBoxInstance.get('settings');
    if (json == null) return AppSettingsModel.defaults;
    return AppSettingsModel.fromJson(Map<String, dynamic>.from(json as Map));
  }

  /// Update settings
  Future<AppSettingsModel> updateSettings(AppSettingsModel settings) async {
    await _settingsBoxInstance.put('settings', settings.toJson());
    return settings;
  }

  // ============ STATISTICS ============

  /// Get time statistics
  TimeStatsModel getTimeStats() {
    final activities = getActivities();
    final now = DateTime.now();
    
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: now.weekday % 7));
    final monthStart = DateTime(now.year, now.month, 1);

    final stats = TimeStatsModel(
      today: _calculatePeriodStats(activities, todayStart),
      week: _calculatePeriodStats(activities, weekStart),
      month: _calculatePeriodStats(activities, monthStart),
      total: _calculatePeriodStats(activities, DateTime(2000)),
    );

    return stats;
  }

  PeriodStats _calculatePeriodStats(List<ActivityModel> activities, DateTime startDate) {
    double wasted = 0;
    double productive = 0;

    for (final activity in activities) {
      if (activity.date.isAfter(startDate.subtract(const Duration(seconds: 1)))) {
        final hours = activity.duration / 60;
        if (activity.isProductive) {
          productive += hours;
        } else {
          wasted += hours;
        }
      }
    }

    return PeriodStats(
      wasted: double.parse(wasted.toStringAsFixed(1)),
      productive: double.parse(productive.toStringAsFixed(1)),
    );
  }

  /// Get daily totals for calendar
  DailyTotals getDailyTotals() {
    final activities = getActivities();
    final totals = DailyTotals(data: {});

    for (final activity in activities) {
      final key = _dateKey(activity.date);
      final existing = totals.data[key] ?? DayData(wasted: 0, productive: 0);
      final hours = activity.duration / 60;

      totals.data[key] = DayData(
        wasted: existing.wasted + (activity.isProductive ? 0 : hours),
        productive: existing.productive + (activity.isProductive ? hours : 0),
      );
    }

    // Round values
    for (final key in totals.data.keys) {
      final data = totals.data[key]!;
      totals.data[key] = DayData(
        wasted: double.parse(data.wasted.toStringAsFixed(1)),
        productive: double.parse(data.productive.toStringAsFixed(1)),
      );
    }

    return totals;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get weekly chart data
  List<ChartDataPoint> getWeeklyChartData() {
    final now = DateTime.now();
    final data = <ChartDataPoint>[];

    for (var i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayActivities = getActivitiesForDay(date);
      
      double wasted = 0;
      double productive = 0;

      for (final activity in dayActivities) {
        final hours = activity.duration / 60;
        if (activity.isProductive) {
          productive += hours;
        } else {
          wasted += hours;
        }
      }

      final dayName = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7];
      
      data.add(ChartDataPoint(
        label: dayName,
        wasted: double.parse(wasted.toStringAsFixed(1)),
        productive: double.parse(productive.toStringAsFixed(1)),
      ));
    }

    return data;
  }

  // ============ DATA EXPORT/IMPORT ============

  /// Export all data
  Map<String, dynamic> exportData() {
    return {
      'activities': getActivities().map((a) => a.toJson()).toList(),
      'settings': getSettings().toJson(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Import data
  Future<bool> importData(Map<String, dynamic> data) async {
    try {
      // Import activities
      if (data['activities'] != null) {
        await clearActivities();
        for (final json in data['activities'] as List) {
          final activity = ActivityModel.fromJson(Map<String, dynamic>.from(json as Map));
          await _activitiesBoxInstance.put(activity.id, activity);
        }
      }

      // Import settings
      if (data['settings'] != null) {
        final settings = AppSettingsModel.fromJson(
          Map<String, dynamic>.from(data['settings'] as Map),
        );
        await updateSettings(settings);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear all data
  Future<void> clearAllData() async {
    await _activitiesBoxInstance.clear();
    await _settingsBoxInstance.clear();
  }
}




