import 'dart:async';
import 'dart:io';
import '../models/models.dart';
import 'platform_channel_service.dart';
import 'storage_service.dart';

/// High-level service for tracking app usage
/// Manages hybrid tracking mode (background + on-demand)
class UsageTrackingService {
  final PlatformChannelService _platformChannel;
  final StorageService _storage;

  Timer? _syncTimer;
  TrackingMode _currentMode = TrackingMode.hybrid;
  bool _isInitialized = false;

  UsageTrackingService(this._platformChannel, this._storage);

  /// Check if native tracking is available
  bool get isNativeTrackingAvailable => _platformChannel.isNativeTrackingAvailable;

  /// Get current tracking mode
  TrackingMode get currentMode => _currentMode;

  /// Check if tracking is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the tracking service
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (Platform.isAndroid) {
      final hasPermission = await _platformChannel.hasUsagePermission();
      if (hasPermission) {
        _currentMode = TrackingMode.hybrid;
        await startPeriodicSync();
      } else {
        _currentMode = TrackingMode.manual;
      }
    } else {
      // iOS: Manual-only mode
      _currentMode = TrackingMode.manual;
    }

    _isInitialized = true;
  }

  /// Check if usage permission is granted
  Future<bool> hasPermission() async {
    if (!isNativeTrackingAvailable) return false;
    return _platformChannel.hasUsagePermission();
  }

  /// Request usage permission
  Future<void> requestPermission() async {
    if (!isNativeTrackingAvailable) return;
    await _platformChannel.requestUsagePermission();
  }

  /// Check and request permission, returns true if granted
  Future<bool> checkAndRequestPermission() async {
    if (!isNativeTrackingAvailable) return false;

    final hasPermission = await _platformChannel.hasUsagePermission();
    if (hasPermission) return true;

    await _platformChannel.requestUsagePermission();
    // User will be redirected to settings, we can't know immediately if they granted
    return false;
  }

  /// Fetch usage data for a time range
  Future<List<NativeAppUsage>> fetchUsageData({
    required DateTime start,
    required DateTime end,
  }) async {
    if (!isNativeTrackingAvailable) return [];

    return _platformChannel.getUsageStats(startTime: start, endTime: end);
  }

  /// Get today's usage stats
  Future<List<NativeAppUsage>> getTodayUsage() async {
    if (!isNativeTrackingAvailable) return [];
    return _platformChannel.getTodayUsageStats();
  }

  /// Get weekly usage stats
  Future<List<NativeAppUsage>> getWeeklyUsage() async {
    if (!isNativeTrackingAvailable) return [];
    return _platformChannel.getWeeklyUsageStats();
  }

  /// Get list of installed apps
  Future<List<InstalledApp>> getInstalledApps() async {
    if (!isNativeTrackingAvailable) return [];
    return _platformChannel.getInstalledApps();
  }

  /// Sync usage data (manual refresh)
  Future<List<NativeAppUsage>> syncUsageData() async {
    if (!isNativeTrackingAvailable) return [];

    final hasPermission = await _platformChannel.hasUsagePermission();
    if (!hasPermission) return [];

    final usage = await getTodayUsage();

    // Save tracking settings with last sync time
    final settings = _storage.getTrackingSettings();
    await _storage.updateTrackingSettings(
      settings.copyWith(lastSyncTime: DateTime.now()),
    );

    return usage;
  }

  /// Start periodic sync
  Future<void> startPeriodicSync({Duration interval = const Duration(minutes: 15)}) async {
    stopPeriodicSync();

    _syncTimer = Timer.periodic(interval, (_) async {
      await syncUsageData();
    });
  }

  /// Stop periodic sync
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Transform native usage data to ActivityModel list
  List<ActivityModel> transformToActivities(List<NativeAppUsage> usageData) {
    final now = DateTime.now();
    final activities = <ActivityModel>[];

    for (final usage in usageData) {
      if (usage.totalMinutes < 1) continue; // Skip apps with less than 1 minute usage

      final category = AppPackages.getCategory(usage.packageName) ?? usage.category;
      final isProductive = AppPackages.isProductive(usage.packageName) || usage.isProductive;
      final displayName = AppPackages.getDisplayName(usage.packageName) ?? usage.appName;

      activities.add(ActivityModel(
        id: '${usage.packageName}_${now.millisecondsSinceEpoch}',
        app: displayName,
        appIcon: AppPackages.getCategoryIcon(category),
        appColor: AppPackages.getCategoryColor(category),
        category: category,
        duration: usage.totalMinutes,
        date: usage.lastUsed ?? now,
        isProductive: isProductive,
        createdAt: now,
      ));
    }

    return activities;
  }

  /// Get merged activities (native + manual)
  Future<List<ActivityModel>> getMergedActivities({
    DateTime? start,
    DateTime? end,
  }) async {
    final manualActivities = start != null && end != null
        ? _storage.getActivitiesByDateRange(start, end)
        : _storage.getActivities();

    if (!isNativeTrackingAvailable) {
      return manualActivities;
    }

    final hasPermission = await _platformChannel.hasUsagePermission();
    if (!hasPermission) {
      return manualActivities;
    }

    final nativeUsage = start != null && end != null
        ? await fetchUsageData(start: start, end: end)
        : await getTodayUsage();

    final nativeActivities = transformToActivities(nativeUsage);

    // Merge and deduplicate
    final merged = <ActivityModel>[];
    merged.addAll(nativeActivities);

    // Add manual activities that aren't duplicates
    for (final manual in manualActivities) {
      final isDuplicate = nativeActivities.any((native) =>
          native.app.toLowerCase() == manual.app.toLowerCase() &&
          native.date.day == manual.date.day &&
          native.date.month == manual.date.month &&
          native.date.year == manual.date.year);

      if (!isDuplicate) {
        merged.add(manual);
      }
    }

    // Sort by date descending
    merged.sort((a, b) => b.date.compareTo(a.date));

    return merged;
  }

  /// Dispose the service
  void dispose() {
    stopPeriodicSync();
  }
}

/// Tracking mode enum
enum TrackingMode {
  manual,     // Manual logging only (iOS)
  automatic,  // Native tracking only (Android with permission)
  hybrid,     // Background + manual refresh (Android with permission)
}

/// Extension for tracking mode
extension TrackingModeExtension on TrackingMode {
  bool get isManualOnly => this == TrackingMode.manual;
  bool get hasNativeTracking => this == TrackingMode.automatic || this == TrackingMode.hybrid;

  String get displayName {
    switch (this) {
      case TrackingMode.manual:
        return 'Manual Logging';
      case TrackingMode.automatic:
        return 'Automatic';
      case TrackingMode.hybrid:
        return 'Hybrid';
    }
  }

  String get description {
    switch (this) {
      case TrackingMode.manual:
        return 'Log your app usage manually';
      case TrackingMode.automatic:
        return 'Automatically tracks app usage';
      case TrackingMode.hybrid:
        return 'Auto-tracking with manual refresh';
    }
  }
}
