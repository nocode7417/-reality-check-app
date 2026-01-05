import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/services.dart';
import '../../data/models/models.dart';

// ============ SERVICE PROVIDERS ============

/// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Analytics service provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

// ============ STATE PROVIDERS ============

/// Activities list provider
final activitiesProvider = StateNotifierProvider<ActivitiesNotifier, List<ActivityModel>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ActivitiesNotifier(storage);
});

/// Time stats provider
final timeStatsProvider = Provider<TimeStatsModel>((ref) {
  // Watch activities to auto-update when they change
  ref.watch(activitiesProvider);
  final storage = ref.read(storageServiceProvider);
  return storage.getTimeStats();
});

/// Daily totals provider for calendar
final dailyTotalsProvider = Provider<DailyTotals>((ref) {
  ref.watch(activitiesProvider);
  final storage = ref.read(storageServiceProvider);
  return storage.getDailyTotals();
});

/// Weekly chart data provider
final weeklyChartDataProvider = Provider<List<ChartDataPoint>>((ref) {
  ref.watch(activitiesProvider);
  final storage = ref.read(storageServiceProvider);
  return storage.getWeeklyChartData();
});

/// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettingsModel>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SettingsNotifier(storage);
});

/// Reality check message provider
final realityCheckMessageProvider = Provider<String>((ref) {
  final stats = ref.watch(timeStatsProvider);
  return CalculationService.getRealityCheckMessage(stats.week.wasted, context: 'week');
});

/// Weekly comparison provider
final weeklyComparisonProvider = Provider<WeeklyComparison>((ref) {
  final stats = ref.watch(timeStatsProvider);
  // For now, compare with 10% more (simulated previous week)
  final previousWeek = stats.week.wasted * 1.1;
  return CalculationService.calculateWeeklyComparison(stats.week.wasted, previousWeek);
});

/// Potential earnings provider
final potentialEarningsProvider = Provider<int>((ref) {
  final stats = ref.watch(timeStatsProvider);
  return (stats.week.wasted * 12).round(); // ~$12/hr average
});

/// Learning days provider
final learningDaysProvider = Provider<int>((ref) {
  final stats = ref.watch(timeStatsProvider);
  return (stats.week.wasted / 2).round(); // 2hrs/day practice
});

// ============ NOTIFIERS ============

/// Activities state notifier
class ActivitiesNotifier extends StateNotifier<List<ActivityModel>> {
  final StorageService _storage;

  ActivitiesNotifier(this._storage) : super([]) {
    _loadActivities();
  }

  void _loadActivities() {
    state = _storage.getActivities();
  }

  Future<ActivityModel> addActivity({
    required AppInfo app,
    required int duration,
  }) async {
    final activity = await _storage.saveActivity(
      app: app.name,
      appIcon: app.icon,
      appColor: app.color,
      category: app.category,
      duration: duration,
      isProductive: app.isProductive,
    );
    state = [activity, ...state];
    return activity;
  }

  Future<void> deleteActivity(String id) async {
    await _storage.deleteActivity(id);
    state = state.where((a) => a.id != id).toList();
  }

  Future<void> clearAll() async {
    await _storage.clearActivities();
    state = [];
  }

  void refresh() {
    _loadActivities();
  }
}

/// Settings state notifier
class SettingsNotifier extends StateNotifier<AppSettingsModel> {
  final StorageService _storage;

  SettingsNotifier(this._storage) : super(AppSettingsModel.defaults) {
    _loadSettings();
  }

  void _loadSettings() {
    state = _storage.getSettings();
  }

  Future<void> updateWeeklyGoal(int hours) async {
    final updated = state.copyWith(weeklyGoal: hours);
    await _storage.updateSettings(updated);
    state = updated;
  }

  Future<void> setOnboardingComplete() async {
    final updated = state.copyWith(onboardingComplete: true);
    await _storage.updateSettings(updated);
    state = updated;
  }

  Future<void> toggleNotifications(bool enabled) async {
    final updated = state.copyWith(notificationsEnabled: enabled);
    await _storage.updateSettings(updated);
    state = updated;
  }
}

// ============ UI STATE PROVIDERS ============

/// Selected app in logger
final selectedAppProvider = StateProvider<AppInfo?>((ref) => null);

/// Selected duration in logger
final selectedDurationProvider = StateProvider<int>((ref) => 30);

/// Selected day in calendar
final selectedDayProvider = StateProvider<DateTime?>((ref) => null);

/// Current month in calendar
final currentMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Bottom navigation current index
final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// Loading state
final isLoadingProvider = StateProvider<bool>((ref) => false);

/// Success toast state
final showSuccessToastProvider = StateProvider<bool>((ref) => false);

/// Last logged activity for toast
final lastLoggedActivityProvider = StateProvider<ActivityModel?>((ref) => null);




