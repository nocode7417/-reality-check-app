/// Model for tracking settings and preferences
class TrackingSettingsModel {
  final bool permissionGranted;
  final bool backgroundSyncEnabled;
  final int syncIntervalMinutes;
  final DateTime? lastSyncTime;
  final bool showPermissionReminder;
  final List<String> excludedPackages;
  final Map<String, String> customCategories;
  final bool hasSeenPermissionScreen;

  TrackingSettingsModel({
    this.permissionGranted = false,
    this.backgroundSyncEnabled = true,
    this.syncIntervalMinutes = 15,
    this.lastSyncTime,
    this.showPermissionReminder = true,
    this.excludedPackages = const [],
    this.customCategories = const {},
    this.hasSeenPermissionScreen = false,
  });

  /// Default settings
  static TrackingSettingsModel get defaults => TrackingSettingsModel();

  /// Check if sync is needed based on interval
  bool get needsSync {
    if (lastSyncTime == null) return true;
    final elapsed = DateTime.now().difference(lastSyncTime!);
    return elapsed.inMinutes >= syncIntervalMinutes;
  }

  /// Time since last sync formatted
  String get timeSinceLastSync {
    if (lastSyncTime == null) return 'Never synced';

    final elapsed = DateTime.now().difference(lastSyncTime!);
    if (elapsed.inMinutes < 1) return 'Just now';
    if (elapsed.inMinutes < 60) return '${elapsed.inMinutes}m ago';
    if (elapsed.inHours < 24) return '${elapsed.inHours}h ago';
    return '${elapsed.inDays}d ago';
  }

  factory TrackingSettingsModel.fromJson(Map<String, dynamic> json) {
    return TrackingSettingsModel(
      permissionGranted: json['permissionGranted'] as bool? ?? false,
      backgroundSyncEnabled: json['backgroundSyncEnabled'] as bool? ?? true,
      syncIntervalMinutes: json['syncIntervalMinutes'] as int? ?? 15,
      lastSyncTime: json['lastSyncTime'] != null
          ? DateTime.parse(json['lastSyncTime'] as String)
          : null,
      showPermissionReminder: json['showPermissionReminder'] as bool? ?? true,
      excludedPackages: (json['excludedPackages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      customCategories: (json['customCategories'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as String)) ??
          {},
      hasSeenPermissionScreen: json['hasSeenPermissionScreen'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'permissionGranted': permissionGranted,
      'backgroundSyncEnabled': backgroundSyncEnabled,
      'syncIntervalMinutes': syncIntervalMinutes,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
      'showPermissionReminder': showPermissionReminder,
      'excludedPackages': excludedPackages,
      'customCategories': customCategories,
      'hasSeenPermissionScreen': hasSeenPermissionScreen,
    };
  }

  TrackingSettingsModel copyWith({
    bool? permissionGranted,
    bool? backgroundSyncEnabled,
    int? syncIntervalMinutes,
    DateTime? lastSyncTime,
    bool? showPermissionReminder,
    List<String>? excludedPackages,
    Map<String, String>? customCategories,
    bool? hasSeenPermissionScreen,
  }) {
    return TrackingSettingsModel(
      permissionGranted: permissionGranted ?? this.permissionGranted,
      backgroundSyncEnabled: backgroundSyncEnabled ?? this.backgroundSyncEnabled,
      syncIntervalMinutes: syncIntervalMinutes ?? this.syncIntervalMinutes,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      showPermissionReminder: showPermissionReminder ?? this.showPermissionReminder,
      excludedPackages: excludedPackages ?? this.excludedPackages,
      customCategories: customCategories ?? this.customCategories,
      hasSeenPermissionScreen: hasSeenPermissionScreen ?? this.hasSeenPermissionScreen,
    );
  }

  @override
  String toString() {
    return 'TrackingSettingsModel(permissionGranted: $permissionGranted, lastSync: $timeSinceLastSync)';
  }
}

/// Permission state enum
enum PermissionState {
  unknown,
  checking,
  granted,
  denied,
  requesting,
}

/// Extension for permission state
extension PermissionStateExtension on PermissionState {
  bool get isGranted => this == PermissionState.granted;
  bool get isDenied => this == PermissionState.denied;
  bool get isChecking => this == PermissionState.checking || this == PermissionState.requesting;
  bool get isUnknown => this == PermissionState.unknown;
}
