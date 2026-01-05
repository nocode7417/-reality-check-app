import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme.dart';
import 'data/services/services.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar configuration will be set dynamically in RealityCheckApp
  // based on current theme (light/dark mode)

  // Initialize storage
  final storageService = StorageService();
  await storageService.init();

  // Initialize analytics
  final analyticsService = AnalyticsService();
  await analyticsService.init();

  // Generate mock data if empty (for demo purposes)
  await _initializeDemoData(storageService);

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
        analyticsServiceProvider.overrideWithValue(analyticsService),
      ],
      child: const RealityCheckApp(),
    ),
  );
}

/// Initialize demo data for first-time users
Future<void> _initializeDemoData(StorageService storage) async {
  final activities = storage.getActivities();
  if (activities.isEmpty) {
    // Generate 30 days of demo data
    final now = DateTime.now();
    
    for (var i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final numActivities = 3 + (i % 5); // 3-7 activities per day
      
      for (var j = 0; j < numActivities; j++) {
        final isProductive = j % 3 == 0; // ~33% productive
        final categories = isProductive
            ? ['Work/Study', 'Learning', 'Exercise', 'Reading']
            : ['Instagram', 'YouTube', 'TikTok', 'Netflix', 'Mobile Games'];
        final icons = isProductive
            ? ['📚', '🎓', '🏃', '📖']
            : ['📸', '▶️', '🎵', '🎥', '📱'];
        final colors = isProductive
            ? ['#4ADE80', '#22C55E', '#10B981', '#059669']
            : ['#E4405F', '#FF0000', '#000000', '#E50914', '#7B68EE'];
        
        final idx = j % categories.length;
        
        await storage.saveActivity(
          app: categories[idx],
          appIcon: icons[idx],
          appColor: colors[idx],
          category: isProductive ? 'Productive' : 'Entertainment',
          duration: 15 + (j * 15) + (i % 3) * 10, // 15-120 minutes
          isProductive: isProductive,
          date: DateTime(date.year, date.month, date.day, 8 + j * 2),
        );
      }
    }
  }
}

/// Main application widget
class RealityCheckApp extends ConsumerWidget {
  const RealityCheckApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Reality Check',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system, // Respects system preference
      routerConfig: appRouter,
      builder: (context, child) {
        // Update status bar dynamically based on theme
        final brightness = MediaQuery.of(context).platformBrightness;
        final isDark = brightness == Brightness.dark;

        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ));

        // Constrain to mobile width
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.maxWidth),
            child: child,
          ),
        );
      },
    );
  }
}




