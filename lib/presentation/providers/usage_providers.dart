import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/services.dart';
import '../../data/models/models.dart';
import 'app_providers.dart';

// ============ SERVICE PROVIDERS ============

/// Platform channel service provider
final platformChannelServiceProvider = Provider<PlatformChannelService>((ref) {
  return PlatformChannelService();
});

/// Usage tracking service provider
final usageTrackingServiceProvider = Provider<UsageTrackingService>((ref) {
  final platform = ref.watch(platformChannelServiceProvider);
  final storage = ref.watch(storageServiceProvider);
  return UsageTrackingService(platform, storage);
});

/// Icon cache service provider
final iconCacheServiceProvider = Provider<IconCacheService>((ref) {
  final platform = ref.watch(platformChannelServiceProvider);
  return IconCacheService(platform);
});

// ============ STATE PROVIDERS ============

/// Permission state provider
final usagePermissionProvider = StateNotifierProvider<PermissionNotifier, PermissionState>((ref) {
  final tracking = ref.watch(usageTrackingServiceProvider);
  final storage = ref.watch(storageServiceProvider);
  return PermissionNotifier(tracking, storage);
});

/// Tracking settings provider
final trackingSettingsProvider = StateNotifierProvider<TrackingSettingsNotifier, TrackingSettingsModel>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return TrackingSettingsNotifier(storage);
});

/// Is Android platform check
final isAndroidProvider = Provider<bool>((ref) {
  return Platform.isAndroid;
});

/// Native tracking available check
final isNativeTrackingAvailableProvider = Provider<bool>((ref) {
  return Platform.isAndroid;
});

// ============ DATA PROVIDERS ============

/// Today's native usage data
final todayUsageProvider = FutureProvider<List<NativeAppUsage>>((ref) async {
  final tracking = ref.watch(usageTrackingServiceProvider);
  final permission = ref.watch(usagePermissionProvider);

  if (!permission.isGranted) return [];

  return tracking.getTodayUsage();
});

/// Weekly native usage data
final weeklyUsageProvider = FutureProvider<List<NativeAppUsage>>((ref) async {
  final tracking = ref.watch(usageTrackingServiceProvider);
  final permission = ref.watch(usagePermissionProvider);

  if (!permission.isGranted) return [];

  return tracking.getWeeklyUsage();
});

/// Installed apps list
final installedAppsProvider = FutureProvider<List<InstalledApp>>((ref) async {
  final tracking = ref.watch(usageTrackingServiceProvider);
  final permission = ref.watch(usagePermissionProvider);

  if (!permission.isGranted) return [];

  return tracking.getInstalledApps();
});

/// Merged activities (native + manual)
final mergedActivitiesProvider = FutureProvider<List<ActivityModel>>((ref) async {
  final tracking = ref.watch(usageTrackingServiceProvider);
  // Watch for changes in manual activities
  ref.watch(activitiesProvider);
  // Watch for permission changes
  ref.watch(usagePermissionProvider);

  return tracking.getMergedActivities();
});

/// App icon provider (cached)
final appIconProvider = FutureProvider.family<Uint8List?, String>((ref, packageName) async {
  final iconCache = ref.watch(iconCacheServiceProvider);
  return iconCache.getIcon(packageName);
});

/// Top apps today (sorted by usage time)
final topAppsTodayProvider = Provider<List<NativeAppUsage>>((ref) {
  final usageAsync = ref.watch(todayUsageProvider);

  return usageAsync.when(
    data: (usage) {
      final sorted = List<NativeAppUsage>.from(usage);
      sorted.sort((a, b) => b.totalTimeMs.compareTo(a.totalTimeMs));
      return sorted.take(5).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Total wasted time today from native tracking
final nativeWastedTodayProvider = Provider<double>((ref) {
  final usageAsync = ref.watch(todayUsageProvider);

  return usageAsync.when(
    data: (usage) {
      double totalMs = 0;
      for (final app in usage) {
        if (!app.isProductive) {
          totalMs += app.totalTimeMs;
        }
      }
      return totalMs / 3600000; // Convert to hours
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Total productive time today from native tracking
final nativeProductiveTodayProvider = Provider<double>((ref) {
  final usageAsync = ref.watch(todayUsageProvider);

  return usageAsync.when(
    data: (usage) {
      double totalMs = 0;
      for (final app in usage) {
        if (app.isProductive) {
          totalMs += app.totalTimeMs;
        }
      }
      return totalMs / 3600000; // Convert to hours
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Sync status provider
final lastSyncTimeProvider = Provider<DateTime?>((ref) {
  final settings = ref.watch(trackingSettingsProvider);
  return settings.lastSyncTime;
});

/// Sync needed provider
final syncNeededProvider = Provider<bool>((ref) {
  final settings = ref.watch(trackingSettingsProvider);
  return settings.needsSync;
});

// ============ NOTIFIERS ============

/// Permission state notifier
class PermissionNotifier extends StateNotifier<PermissionState> {
  final UsageTrackingService _tracking;
  final StorageService _storage;

  PermissionNotifier(this._tracking, this._storage) : super(PermissionState.unknown) {
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    state = PermissionState.checking;

    if (!_tracking.isNativeTrackingAvailable) {
      state = PermissionState.denied;
      return;
    }

    final hasPermission = await _tracking.hasPermission();
    state = hasPermission ? PermissionState.granted : PermissionState.denied;

    // Update stored settings
    await _storage.setPermissionGranted(hasPermission);
  }

  Future<void> requestPermission() async {
    state = PermissionState.requesting;
    await _tracking.requestPermission();
    // Note: We can't know immediately if permission was granted
    // User needs to manually enable in settings
    // Check again after a delay
  }

  Future<void> checkPermission() async {
    await _checkPermission();
  }

  Future<void> refresh() async {
    await _checkPermission();
  }
}

/// Tracking settings state notifier
class TrackingSettingsNotifier extends StateNotifier<TrackingSettingsModel> {
  final StorageService _storage;

  TrackingSettingsNotifier(this._storage) : super(TrackingSettingsModel.defaults) {
    _loadSettings();
  }

  void _loadSettings() {
    state = _storage.getTrackingSettings();
  }

  Future<void> updateSyncInterval(int minutes) async {
    final updated = state.copyWith(syncIntervalMinutes: minutes);
    await _storage.updateTrackingSettings(updated);
    state = updated;
  }

  Future<void> toggleBackgroundSync(bool enabled) async {
    final updated = state.copyWith(backgroundSyncEnabled: enabled);
    await _storage.updateTrackingSettings(updated);
    state = updated;
  }

  Future<void> addExcludedApp(String packageName) async {
    final excludedPackages = [...state.excludedPackages, packageName];
    final updated = state.copyWith(excludedPackages: excludedPackages);
    await _storage.updateTrackingSettings(updated);
    state = updated;
  }

  Future<void> removeExcludedApp(String packageName) async {
    final excludedPackages = state.excludedPackages.where((p) => p != packageName).toList();
    final updated = state.copyWith(excludedPackages: excludedPackages);
    await _storage.updateTrackingSettings(updated);
    state = updated;
  }

  Future<void> setCustomCategory(String packageName, String category) async {
    final customCategories = {...state.customCategories, packageName: category};
    final updated = state.copyWith(customCategories: customCategories);
    await _storage.updateTrackingSettings(updated);
    state = updated;
  }

  Future<void> updateLastSyncTime() async {
    final updated = state.copyWith(lastSyncTime: DateTime.now());
    await _storage.updateTrackingSettings(updated);
    state = updated;
  }

  Future<void> markPermissionScreenSeen() async {
    final updated = state.copyWith(hasSeenPermissionScreen: true);
    await _storage.updateTrackingSettings(updated);
    state = updated;
  }

  Future<void> setPermissionGranted(bool granted) async {
    final updated = state.copyWith(permissionGranted: granted);
    await _storage.updateTrackingSettings(updated);
    state = updated;
  }

  void refresh() {
    _loadSettings();
  }
}
