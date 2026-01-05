import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme.dart';
import 'data/services/services.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/providers/app_providers.dart';
import 'presentation/providers/usage_providers.dart';

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

  // Initialize platform channel service for native tracking
  final platformChannelService = PlatformChannelService();

  // Initialize icon cache service
  final iconCacheService = IconCacheService(platformChannelService);
  await iconCacheService.initialize();

  // Initialize usage tracking service
  final usageTrackingService = UsageTrackingService(platformChannelService, storageService);
  await usageTrackingService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
        analyticsServiceProvider.overrideWithValue(analyticsService),
        platformChannelServiceProvider.overrideWithValue(platformChannelService),
        iconCacheServiceProvider.overrideWithValue(iconCacheService),
        usageTrackingServiceProvider.overrideWithValue(usageTrackingService),
      ],
      child: const RealityCheckApp(),
    ),
  );
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




