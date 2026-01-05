import 'package:hive/hive.dart';

part 'activity_model.g.dart';

/// Activity data model for logging time spent on apps
@HiveType(typeId: 0)
class ActivityModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String app;

  @HiveField(2)
  final String appIcon;

  @HiveField(3)
  final String appColor;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final int duration; // in minutes

  @HiveField(6)
  final DateTime date;

  @HiveField(7)
  final bool isProductive;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime? updatedAt;

  ActivityModel({
    required this.id,
    required this.app,
    required this.appIcon,
    required this.appColor,
    required this.category,
    required this.duration,
    required this.date,
    required this.isProductive,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      app: json['app'] as String,
      appIcon: json['appIcon'] as String,
      appColor: json['appColor'] as String,
      category: json['category'] as String,
      duration: json['duration'] as int,
      date: DateTime.parse(json['date'] as String),
      isProductive: json['isProductive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'app': app,
      'appIcon': appIcon,
      'appColor': appColor,
      'category': category,
      'duration': duration,
      'date': date.toIso8601String(),
      'isProductive': isProductive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Copy with
  ActivityModel copyWith({
    String? id,
    String? app,
    String? appIcon,
    String? appColor,
    String? category,
    int? duration,
    DateTime? date,
    bool? isProductive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      app: app ?? this.app,
      appIcon: appIcon ?? this.appIcon,
      appColor: appColor ?? this.appColor,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      date: date ?? this.date,
      isProductive: isProductive ?? this.isProductive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Hours spent (for calculations)
  double get hours => duration / 60;

  @override
  String toString() {
    return 'ActivityModel(app: $app, duration: ${duration}m, productive: $isProductive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActivityModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}




