/// App information for logging
class AppInfo {
  final String name;
  final String icon;
  final String color;
  final String category;
  final bool isProductive;

  const AppInfo({
    required this.name,
    required this.icon,
    required this.color,
    required this.category,
    required this.isProductive,
  });

  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      category: json['category'] as String,
      isProductive: json['isProductive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
      'color': color,
      'category': category,
      'isProductive': isProductive,
    };
  }
}

/// App category with list of apps
class AppCategory {
  final String name;
  final String icon;
  final bool isProductive;
  final List<AppInfo> apps;

  const AppCategory({
    required this.name,
    required this.icon,
    required this.isProductive,
    required this.apps,
  });
}

/// Predefined app categories matching web app
class AppCategories {
  static const AppCategory socialMedia = AppCategory(
    name: 'Social Media',
    icon: '📱',
    isProductive: false,
    apps: [
      AppInfo(name: 'Instagram', icon: '📸', color: '#E4405F', category: 'Social Media', isProductive: false),
      AppInfo(name: 'TikTok', icon: '🎵', color: '#000000', category: 'Social Media', isProductive: false),
      AppInfo(name: 'Twitter/X', icon: '🐦', color: '#1DA1F2', category: 'Social Media', isProductive: false),
      AppInfo(name: 'Snapchat', icon: '👻', color: '#FFFC00', category: 'Social Media', isProductive: false),
      AppInfo(name: 'Facebook', icon: '👤', color: '#1877F2', category: 'Social Media', isProductive: false),
      AppInfo(name: 'Reddit', icon: '🔴', color: '#FF4500', category: 'Social Media', isProductive: false),
    ],
  );

  static const AppCategory streaming = AppCategory(
    name: 'Streaming',
    icon: '🎬',
    isProductive: false,
    apps: [
      AppInfo(name: 'YouTube', icon: '▶️', color: '#FF0000', category: 'Streaming', isProductive: false),
      AppInfo(name: 'Netflix', icon: '🎥', color: '#E50914', category: 'Streaming', isProductive: false),
      AppInfo(name: 'Twitch', icon: '🎮', color: '#9146FF', category: 'Streaming', isProductive: false),
      AppInfo(name: 'Spotify', icon: '🎧', color: '#1DB954', category: 'Streaming', isProductive: false),
      AppInfo(name: 'Disney+', icon: '✨', color: '#113CCF', category: 'Streaming', isProductive: false),
    ],
  );

  static const AppCategory gaming = AppCategory(
    name: 'Gaming',
    icon: '🎮',
    isProductive: false,
    apps: [
      AppInfo(name: 'Mobile Games', icon: '📱', color: '#7B68EE', category: 'Gaming', isProductive: false),
      AppInfo(name: 'Console/PC', icon: '🖥️', color: '#00D4FF', category: 'Gaming', isProductive: false),
      AppInfo(name: 'Discord', icon: '💬', color: '#5865F2', category: 'Gaming', isProductive: false),
    ],
  );

  static const AppCategory shopping = AppCategory(
    name: 'Shopping',
    icon: '🛒',
    isProductive: false,
    apps: [
      AppInfo(name: 'Amazon', icon: '📦', color: '#FF9900', category: 'Shopping', isProductive: false),
      AppInfo(name: 'eBay', icon: '🏷️', color: '#E53238', category: 'Shopping', isProductive: false),
      AppInfo(name: 'Browsing', icon: '🌐', color: '#4285F4', category: 'Shopping', isProductive: false),
    ],
  );

  static const AppCategory productive = AppCategory(
    name: 'Productive',
    icon: '💼',
    isProductive: true,
    apps: [
      AppInfo(name: 'Work/Study', icon: '📚', color: '#4ADE80', category: 'Productive', isProductive: true),
      AppInfo(name: 'Learning', icon: '🎓', color: '#22C55E', category: 'Productive', isProductive: true),
      AppInfo(name: 'Exercise', icon: '🏃', color: '#10B981', category: 'Productive', isProductive: true),
      AppInfo(name: 'Reading', icon: '📖', color: '#059669', category: 'Productive', isProductive: true),
      AppInfo(name: 'Side Project', icon: '💡', color: '#34D399', category: 'Productive', isProductive: true),
      AppInfo(name: 'Meditation', icon: '🧘', color: '#6EE7B7', category: 'Productive', isProductive: true),
    ],
  );

  /// All categories
  static List<AppCategory> get all => [
    socialMedia,
    streaming,
    gaming,
    shopping,
    productive,
  ];

  /// Get quick selection apps (first 6)
  static List<AppInfo> get quickApps {
    final apps = <AppInfo>[];
    for (final category in all) {
      apps.addAll(category.apps);
    }
    return apps.take(6).toList();
  }

  /// Get all apps flat
  static List<AppInfo> get allApps {
    final apps = <AppInfo>[];
    for (final category in all) {
      apps.addAll(category.apps);
    }
    return apps;
  }
}




