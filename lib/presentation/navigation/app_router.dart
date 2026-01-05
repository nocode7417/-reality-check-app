import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/logger/logger_screen.dart';
import '../widgets/common/app_scaffold.dart';

/// App navigation routes
class AppRoutes {
  static const String dashboard = '/';
  static const String calendar = '/calendar';
  static const String log = '/log';
}

/// GoRouter configuration
final appRouter = GoRouter(
  initialLocation: AppRoutes.dashboard,
  debugLogDiagnostics: true,
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          name: 'dashboard',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const DashboardScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: AppRoutes.calendar,
          name: 'calendar',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const CalendarScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: AppRoutes.log,
          name: 'log',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const LoggerScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
                child: child,
              );
            },
          ),
        ),
      ],
    ),
  ],
);




