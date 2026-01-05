/// App information for logging
class AppInfo {
  final String name;
  final String icon;
  final String color;
  final String category;
  final bool isProductive;
  final String? packageName; // Android package name for native tracking

  const AppInfo({
    required this.name,
    required this.icon,
    required this.color,
    required this.category,
    required this.isProductive,
    this.packageName,
  });

  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      category: json['category'] as String,
      isProductive: json['isProductive'] as bool,
      packageName: json['packageName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
      'color': color,
      'category': category,
      'isProductive': isProductive,
      'packageName': packageName,
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

/// Package name mappings for native Android app tracking
class AppPackages {
  // Social Media package names
  static const Map<String, String> socialMedia = {
    'com.instagram.android': 'Instagram',
    'com.zhiliaoapp.musically': 'TikTok',
    'com.ss.android.ugc.trill': 'TikTok',
    'com.google.android.youtube': 'YouTube',
    'com.twitter.android': 'Twitter/X',
    'com.twitter.android.lite': 'Twitter/X',
    'com.snapchat.android': 'Snapchat',
    'com.facebook.katana': 'Facebook',
    'com.facebook.lite': 'Facebook',
    'com.reddit.frontpage': 'Reddit',
    'com.whatsapp': 'WhatsApp',
    'org.telegram.messenger': 'Telegram',
    'com.pinterest': 'Pinterest',
    'com.linkedin.android': 'LinkedIn',
  };

  // Gaming package names - Priority apps from requirements
  static const Map<String, String> gaming = {
    'com.tencent.ig': 'PUBG Mobile',
    'com.pubg.imobile': 'BGMI',
    'com.pubg.krmobile': 'PUBG KR',
    'com.activision.callofduty.shooter': 'COD Mobile',
    'com.dts.freefireth': 'Free Fire',
    'com.dts.freefiremax': 'Free Fire MAX',
    'com.supercell.clashofclans': 'Clash of Clans',
    'com.supercell.clashroyale': 'Clash Royale',
    'com.miHoYo.GenshinImpact': 'Genshin Impact',
    'com.innersloth.spacemafia': 'Among Us',
    'com.roblox.client': 'Roblox',
    'com.mojang.minecraftpe': 'Minecraft',
    'com.kiloo.subwaysurf': 'Subway Surfers',
    'com.king.candycrushsaga': 'Candy Crush',
    'com.epicgames.fortnite': 'Fortnite',
    'com.mobile.legends': 'Mobile Legends',
    'com.garena.game.codm': 'COD Mobile Garena',
  };

  // Streaming package names
  static const Map<String, String> streaming = {
    'com.netflix.mediaclient': 'Netflix',
    'com.amazon.avod.thirdpartyclient': 'Prime Video',
    'com.disney.disneyplus': 'Disney+',
    'com.spotify.music': 'Spotify',
    'tv.twitch.android.app': 'Twitch',
    'com.hulu.plus': 'Hulu',
    'com.hbo.hbonow': 'HBO Max',
    'com.apple.android.music': 'Apple Music',
    'com.soundcloud.android': 'SoundCloud',
  };

  // Productive package names
  static const Map<String, String> productive = {
    'com.google.android.apps.docs': 'Google Drive',
    'com.google.android.apps.docs.editors.docs': 'Google Docs',
    'com.google.android.apps.docs.editors.sheets': 'Google Sheets',
    'com.google.android.apps.docs.editors.slides': 'Google Slides',
    'com.microsoft.office.word': 'Word',
    'com.microsoft.office.excel': 'Excel',
    'com.microsoft.office.powerpoint': 'PowerPoint',
    'com.microsoft.teams': 'Teams',
    'com.slack': 'Slack',
    'com.notion.id': 'Notion',
    'com.todoist': 'Todoist',
    'com.duolingo': 'Duolingo',
    'com.evernote': 'Evernote',
    'com.trello': 'Trello',
    'com.Slack': 'Slack',
    'com.google.android.keep': 'Google Keep',
    'com.google.android.calendar': 'Google Calendar',
  };

  // Shopping package names
  static const Map<String, String> shopping = {
    'com.amazon.mShop.android.shopping': 'Amazon',
    'com.ebay.mobile': 'eBay',
    'com.alibaba.aliexpresshd': 'AliExpress',
    'com.shopify.mobile': 'Shopify',
    'com.walmart.android': 'Walmart',
    'com.target.ui': 'Target',
  };

  /// Get category for a package name
  static String? getCategory(String packageName) {
    if (socialMedia.containsKey(packageName)) return 'Social Media';
    if (gaming.containsKey(packageName)) return 'Gaming';
    if (streaming.containsKey(packageName)) return 'Streaming';
    if (productive.containsKey(packageName)) return 'Productive';
    if (shopping.containsKey(packageName)) return 'Shopping';
    return null;
  }

  /// Check if package is productive
  static bool isProductive(String packageName) {
    return productive.containsKey(packageName);
  }

  /// Get display name for package
  static String? getDisplayName(String packageName) {
    return socialMedia[packageName] ??
        gaming[packageName] ??
        streaming[packageName] ??
        productive[packageName] ??
        shopping[packageName];
  }

  /// Get all package name mappings
  static Map<String, String> get all => {
        ...socialMedia,
        ...gaming,
        ...streaming,
        ...productive,
        ...shopping,
      };

  /// Get emoji icon for a category
  static String getCategoryIcon(String category) {
    switch (category) {
      case 'Social Media':
        return '📱';
      case 'Gaming':
        return '🎮';
      case 'Streaming':
        return '🎬';
      case 'Productive':
        return '💼';
      case 'Shopping':
        return '🛒';
      default:
        return '📦';
    }
  }

  /// Get color for a category
  static String getCategoryColor(String category) {
    switch (category) {
      case 'Social Media':
        return '#E4405F';
      case 'Gaming':
        return '#7B68EE';
      case 'Streaming':
        return '#FF0000';
      case 'Productive':
        return '#4ADE80';
      case 'Shopping':
        return '#FF9900';
      default:
        return '#6B7280';
    }
  }

  /// Check if category is productive
  static bool isCategoryProductive(String category) {
    return category == 'Productive';
  }
}




