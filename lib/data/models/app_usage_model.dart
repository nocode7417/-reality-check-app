/// Model for storing native app usage data
class AppUsageModel {
  final String packageName;
  final String appName;
  final int totalTimeMs;
  final DateTime lastUsed;
  final DateTime firstUsed;
  final String category;
  final bool isProductive;
  final DateTime recordedAt;
  final DateTime periodStart;
  final DateTime periodEnd;

  AppUsageModel({
    required this.packageName,
    required this.appName,
    required this.totalTimeMs,
    required this.lastUsed,
    required this.firstUsed,
    required this.category,
    required this.isProductive,
    required this.recordedAt,
    required this.periodStart,
    required this.periodEnd,
  });

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

  factory AppUsageModel.fromJson(Map<String, dynamic> json) {
    return AppUsageModel(
      packageName: json['packageName'] as String,
      appName: json['appName'] as String,
      totalTimeMs: json['totalTimeMs'] as int,
      lastUsed: DateTime.parse(json['lastUsed'] as String),
      firstUsed: DateTime.parse(json['firstUsed'] as String),
      category: json['category'] as String,
      isProductive: json['isProductive'] as bool,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'appName': appName,
      'totalTimeMs': totalTimeMs,
      'lastUsed': lastUsed.toIso8601String(),
      'firstUsed': firstUsed.toIso8601String(),
      'category': category,
      'isProductive': isProductive,
      'recordedAt': recordedAt.toIso8601String(),
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
    };
  }

  AppUsageModel copyWith({
    String? packageName,
    String? appName,
    int? totalTimeMs,
    DateTime? lastUsed,
    DateTime? firstUsed,
    String? category,
    bool? isProductive,
    DateTime? recordedAt,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) {
    return AppUsageModel(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      totalTimeMs: totalTimeMs ?? this.totalTimeMs,
      lastUsed: lastUsed ?? this.lastUsed,
      firstUsed: firstUsed ?? this.firstUsed,
      category: category ?? this.category,
      isProductive: isProductive ?? this.isProductive,
      recordedAt: recordedAt ?? this.recordedAt,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
    );
  }

  @override
  String toString() {
    return 'AppUsageModel(appName: $appName, time: $formattedTime, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUsageModel &&
        other.packageName == packageName &&
        other.periodStart == periodStart &&
        other.periodEnd == periodEnd;
  }

  @override
  int get hashCode => packageName.hashCode ^ periodStart.hashCode ^ periodEnd.hashCode;
}

/// Model for installed app information
class InstalledAppModel {
  final String packageName;
  final String appName;
  final String category;
  final bool isProductive;
  final bool hasIcon;
  final DateTime installedAt;
  final DateTime? lastUsed;
  final bool isUninstalled;
  final bool isPrioritized;

  InstalledAppModel({
    required this.packageName,
    required this.appName,
    required this.category,
    required this.isProductive,
    this.hasIcon = false,
    required this.installedAt,
    this.lastUsed,
    this.isUninstalled = false,
    this.isPrioritized = false,
  });

  factory InstalledAppModel.fromJson(Map<String, dynamic> json) {
    return InstalledAppModel(
      packageName: json['packageName'] as String,
      appName: json['appName'] as String,
      category: json['category'] as String,
      isProductive: json['isProductive'] as bool,
      hasIcon: json['hasIcon'] as bool? ?? false,
      installedAt: DateTime.parse(json['installedAt'] as String),
      lastUsed: json['lastUsed'] != null
          ? DateTime.parse(json['lastUsed'] as String)
          : null,
      isUninstalled: json['isUninstalled'] as bool? ?? false,
      isPrioritized: json['isPrioritized'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'appName': appName,
      'category': category,
      'isProductive': isProductive,
      'hasIcon': hasIcon,
      'installedAt': installedAt.toIso8601String(),
      'lastUsed': lastUsed?.toIso8601String(),
      'isUninstalled': isUninstalled,
      'isPrioritized': isPrioritized,
    };
  }

  InstalledAppModel copyWith({
    String? packageName,
    String? appName,
    String? category,
    bool? isProductive,
    bool? hasIcon,
    DateTime? installedAt,
    DateTime? lastUsed,
    bool? isUninstalled,
    bool? isPrioritized,
  }) {
    return InstalledAppModel(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      category: category ?? this.category,
      isProductive: isProductive ?? this.isProductive,
      hasIcon: hasIcon ?? this.hasIcon,
      installedAt: installedAt ?? this.installedAt,
      lastUsed: lastUsed ?? this.lastUsed,
      isUninstalled: isUninstalled ?? this.isUninstalled,
      isPrioritized: isPrioritized ?? this.isPrioritized,
    );
  }

  @override
  String toString() {
    return 'InstalledAppModel(appName: $appName, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InstalledAppModel && other.packageName == packageName;
  }

  @override
  int get hashCode => packageName.hashCode;
}
