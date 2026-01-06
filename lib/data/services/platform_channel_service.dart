import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart';

/// Service for communicating with native platform code
/// Handles Android UsageStatsManager integration
class PlatformChannelService {
  static const MethodChannel _channel = MethodChannel('com.realitycheck/usage_stats');
  static const EventChannel _eventChannel = EventChannel('com.realitycheck/usage_updates');

  Stream<List<NativeAppUsage>>? _usageUpdatesStream;

  /// Check if native tracking is available (Android only)
  bool get isNativeTrackingAvailable => Platform.isAndroid;

  /// Check if usage stats permission is granted
  Future<bool> hasUsagePermission() async {
    if (!isNativeTrackingAvailable) return false;

    try {
      final result = await _channel.invokeMethod<bool>('hasUsagePermission');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Request usage stats permission (opens system settings)
  Future<void> requestUsagePermission() async {
    if (!isNativeTrackingAvailable) return;

    try {
      await _channel.invokeMethod('requestUsagePermission');
    } on PlatformException {
      // Permission request failed, user needs to manually enable
    }
  }

  /// Open app settings (for "Allow restricted settings" on Android 13+)
  Future<void> openAppSettings() async {
    if (!isNativeTrackingAvailable) return;

    try {
      await _channel.invokeMethod('openAppSettings');
    } on PlatformException {
      // Failed to open settings
    }
  }

  /// Open usage access settings directly
  Future<void> openUsageAccessSettings() async {
    if (!isNativeTrackingAvailable) return;

    try {
      await _channel.invokeMethod('openUsageAccessSettings');
    } on PlatformException {
      // Failed to open settings
    }
  }

  /// Get Android SDK version
  Future<int> getAndroidVersion() async {
    if (!isNativeTrackingAvailable) return 0;

    try {
      final result = await _channel.invokeMethod<int>('getAndroidVersion');
      return result ?? 0;
    } on PlatformException {
      return 0;
    }
  }

  /// Check if device is Android 13+ (has restricted settings)
  Future<bool> isRestrictedSettingsDevice() async {
    if (!isNativeTrackingAvailable) return false;

    try {
      final result = await _channel.invokeMethod<bool>('isRestrictedSettingsDevice');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Get package name
  Future<String> getPackageName() async {
    if (!isNativeTrackingAvailable) return '';

    try {
      final result = await _channel.invokeMethod<String>('getPackageName');
      return result ?? '';
    } on PlatformException {
      return '';
    }
  }

  /// Get usage stats for a time range
  Future<List<NativeAppUsage>> getUsageStats({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    if (!isNativeTrackingAvailable) return [];

    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getUsageStats', {
        'startTime': startTime.millisecondsSinceEpoch,
        'endTime': endTime.millisecondsSinceEpoch,
      });

      if (result == null) return [];

      return result.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return NativeAppUsage.fromMap(map);
      }).toList();
    } on PlatformException {
      return [];
    }
  }

  /// Get today's usage stats
  Future<List<NativeAppUsage>> getTodayUsageStats() async {
    if (!isNativeTrackingAvailable) return [];

    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getTodayUsageStats');

      if (result == null) return [];

      return result.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return NativeAppUsage.fromMap(map);
      }).toList();
    } on PlatformException {
      return [];
    }
  }

  /// Get weekly usage stats
  Future<List<NativeAppUsage>> getWeeklyUsageStats() async {
    if (!isNativeTrackingAvailable) return [];

    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getWeeklyUsageStats');

      if (result == null) return [];

      return result.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return NativeAppUsage.fromMap(map);
      }).toList();
    } on PlatformException {
      return [];
    }
  }

  /// Get list of installed apps
  Future<List<InstalledApp>> getInstalledApps() async {
    if (!isNativeTrackingAvailable) return [];

    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getInstalledApps');

      if (result == null) return [];

      return result.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return InstalledApp.fromMap(map);
      }).toList();
    } on PlatformException {
      return [];
    }
  }

  /// Get app icon as bytes (base64 encoded from native)
  Future<Uint8List?> getAppIcon(String packageName) async {
    if (!isNativeTrackingAvailable) return null;

    try {
      final result = await _channel.invokeMethod<String>('getAppIcon', {
        'packageName': packageName,
      });

      if (result == null) return null;

      return base64Decode(result);
    } on PlatformException {
      return null;
    }
  }

  /// Get multiple app icons in batch
  Future<Map<String, Uint8List>> getBatchAppIcons(List<String> packageNames) async {
    if (!isNativeTrackingAvailable) return {};

    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getBatchAppIcons', {
        'packageNames': packageNames,
      });

      if (result == null) return {};

      final icons = <String, Uint8List>{};
      result.forEach((key, value) {
        if (value != null) {
          icons[key as String] = base64Decode(value as String);
        }
      });

      return icons;
    } on PlatformException {
      return {};
    }
  }

  /// Get current foreground app
  Future<NativeAppUsage?> getCurrentForegroundApp() async {
    if (!isNativeTrackingAvailable) return null;

    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getCurrentForegroundApp');

      if (result == null) return null;

      final map = Map<String, dynamic>.from(result);
      return NativeAppUsage.fromMap(map);
    } on PlatformException {
      return null;
    }
  }

  /// Stream of usage updates (for real-time tracking)
  Stream<List<NativeAppUsage>> get usageUpdates {
    _usageUpdatesStream ??= _eventChannel.receiveBroadcastStream().map((data) {
      if (data == null) return <NativeAppUsage>[];

      final list = data as List<dynamic>;
      return list.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return NativeAppUsage.fromMap(map);
      }).toList();
    });

    return _usageUpdatesStream!;
  }
}

/// Native app usage data from Android UsageStatsManager
class NativeAppUsage {
  final String packageName;
  final String appName;
  final int totalTimeMs;
  final DateTime? lastUsed;
  final DateTime? firstUsed;
  final String category;
  final bool isProductive;

  NativeAppUsage({
    required this.packageName,
    required this.appName,
    required this.totalTimeMs,
    this.lastUsed,
    this.firstUsed,
    required this.category,
    required this.isProductive,
  });

  factory NativeAppUsage.fromMap(Map<String, dynamic> map) {
    return NativeAppUsage(
      packageName: map['packageName'] as String? ?? '',
      appName: map['appName'] as String? ?? 'Unknown',
      totalTimeMs: (map['totalTimeMs'] as num?)?.toInt() ?? 0,
      lastUsed: map['lastUsed'] != null
          ? DateTime.fromMillisecondsSinceEpoch((map['lastUsed'] as num).toInt())
          : null,
      firstUsed: map['firstUsed'] != null
          ? DateTime.fromMillisecondsSinceEpoch((map['firstUsed'] as num).toInt())
          : null,
      category: map['category'] as String? ?? 'Other',
      isProductive: map['isProductive'] as bool? ?? false,
    );
  }

  /// Get total time in minutes
  int get totalMinutes => totalTimeMs ~/ 60000;

  /// Get total time in hours
  double get totalHours => totalTimeMs / 3600000;

  /// Get formatted time string
  String get formattedTime {
    final hours = totalTimeMs ~/ 3600000;
    final minutes = (totalTimeMs % 3600000) ~/ 60000;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'appName': appName,
      'totalTimeMs': totalTimeMs,
      'lastUsed': lastUsed?.millisecondsSinceEpoch,
      'firstUsed': firstUsed?.millisecondsSinceEpoch,
      'category': category,
      'isProductive': isProductive,
    };
  }

  @override
  String toString() {
    return 'NativeAppUsage(appName: $appName, time: $formattedTime, category: $category)';
  }
}

/// Installed app information
class InstalledApp {
  final String packageName;
  final String appName;
  final String category;
  final bool isProductive;
  final bool isSystemApp;

  InstalledApp({
    required this.packageName,
    required this.appName,
    required this.category,
    required this.isProductive,
    required this.isSystemApp,
  });

  factory InstalledApp.fromMap(Map<String, dynamic> map) {
    return InstalledApp(
      packageName: map['packageName'] as String? ?? '',
      appName: map['appName'] as String? ?? 'Unknown',
      category: map['category'] as String? ?? 'Other',
      isProductive: map['isProductive'] as bool? ?? false,
      isSystemApp: map['isSystemApp'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'appName': appName,
      'category': category,
      'isProductive': isProductive,
      'isSystemApp': isSystemApp,
    };
  }

  @override
  String toString() {
    return 'InstalledApp(appName: $appName, category: $category)';
  }
}
