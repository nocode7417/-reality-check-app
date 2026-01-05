import 'package:hive/hive.dart';

part 'app_settings_model.g.dart';

/// App settings model for user preferences
@HiveType(typeId: 1)
class AppSettingsModel extends HiveObject {
  @HiveField(0)
  final String region;

  @HiveField(1)
  final int weeklyGoal; // hours of productive time

  @HiveField(2)
  final bool notificationsEnabled;

  @HiveField(3)
  final bool onboardingComplete;

  @HiveField(4)
  final DateTime? lastSyncAt;

  @HiveField(5)
  final String? userId;

  AppSettingsModel({
    this.region = 'US',
    this.weeklyGoal = 40,
    this.notificationsEnabled = true,
    this.onboardingComplete = false,
    this.lastSyncAt,
    this.userId,
  });

  /// Default settings
  static AppSettingsModel get defaults => AppSettingsModel();

  /// Create from JSON
  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      region: json['region'] as String? ?? 'US',
      weeklyGoal: json['weeklyGoal'] as int? ?? 40,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      lastSyncAt: json['lastSyncAt'] != null 
          ? DateTime.parse(json['lastSyncAt'] as String) 
          : null,
      userId: json['userId'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'region': region,
      'weeklyGoal': weeklyGoal,
      'notificationsEnabled': notificationsEnabled,
      'onboardingComplete': onboardingComplete,
      'lastSyncAt': lastSyncAt?.toIso8601String(),
      'userId': userId,
    };
  }

  /// Copy with
  AppSettingsModel copyWith({
    String? region,
    int? weeklyGoal,
    bool? notificationsEnabled,
    bool? onboardingComplete,
    DateTime? lastSyncAt,
    String? userId,
  }) {
    return AppSettingsModel(
      region: region ?? this.region,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      userId: userId ?? this.userId,
    );
  }
}




