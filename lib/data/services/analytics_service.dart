import 'dart:async';
import 'package:flutter/foundation.dart';

/// Privacy-aware analytics service with clear event schema
/// Tracks user behavior without collecting PII
class AnalyticsService {
  // Event queue for batching
  final List<AnalyticsEvent> _eventQueue = [];
  Timer? _batchTimer;
  
  // Session tracking
  DateTime? _sessionStart;
  String? _sessionId;
  int _screenViews = 0;

  /// Initialize analytics (call on app start)
  Future<void> init() async {
    _sessionStart = DateTime.now();
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Start batch timer (send events every 30 seconds)
    _batchTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _flushEvents();
    });

    await _logEvent(AnalyticsEvent(
      name: 'session_start',
      timestamp: DateTime.now(),
    ));
  }

  /// Dispose analytics (call on app close)
  Future<void> dispose() async {
    _batchTimer?.cancel();
    
    if (_sessionStart != null) {
      final duration = DateTime.now().difference(_sessionStart!);
      await _logEvent(AnalyticsEvent(
        name: 'session_end',
        timestamp: DateTime.now(),
        properties: {
          'duration_seconds': duration.inSeconds,
          'screen_views': _screenViews,
        },
      ));
    }

    await _flushEvents();
  }

  // ============ SCREEN TRACKING ============

  /// Log screen view
  Future<void> logScreenView(String screenName) async {
    _screenViews++;
    await _logEvent(AnalyticsEvent(
      name: 'screen_view',
      timestamp: DateTime.now(),
      properties: {
        'screen_name': screenName,
      },
    ));
  }

  // ============ USER ACTIONS ============

  /// Log activity logged
  Future<void> logActivityLogged({
    required String category,
    required int durationMinutes,
    required bool isProductive,
  }) async {
    await _logEvent(AnalyticsEvent(
      name: 'activity_logged',
      timestamp: DateTime.now(),
      properties: {
        'category': category,
        'duration_bucket': _getDurationBucket(durationMinutes),
        'is_productive': isProductive,
      },
    ));
  }

  /// Log calendar day selected
  Future<void> logCalendarDaySelected({
    required bool hasData,
  }) async {
    await _logEvent(AnalyticsEvent(
      name: 'calendar_day_selected',
      timestamp: DateTime.now(),
      properties: {
        'has_data': hasData,
      },
    ));
  }

  /// Log calendar month navigated
  Future<void> logCalendarNavigation(String direction) async {
    await _logEvent(AnalyticsEvent(
      name: 'calendar_navigation',
      timestamp: DateTime.now(),
      properties: {
        'direction': direction,
      },
    ));
  }

  /// Log app card selected
  Future<void> logAppSelected({
    required String category,
  }) async {
    await _logEvent(AnalyticsEvent(
      name: 'app_selected',
      timestamp: DateTime.now(),
      properties: {
        'category': category,
      },
    ));
  }

  /// Log duration changed
  Future<void> logDurationChanged({
    required int durationMinutes,
    required String method, // 'preset' or 'slider'
  }) async {
    await _logEvent(AnalyticsEvent(
      name: 'duration_changed',
      timestamp: DateTime.now(),
      properties: {
        'duration_bucket': _getDurationBucket(durationMinutes),
        'method': method,
      },
    ));
  }

  // ============ ENGAGEMENT METRICS ============

  /// Log streak milestone
  Future<void> logStreakMilestone(int days) async {
    await _logEvent(AnalyticsEvent(
      name: 'streak_milestone',
      timestamp: DateTime.now(),
      properties: {
        'days': days,
      },
    ));
  }

  /// Log goal progress
  Future<void> logGoalProgress({
    required double percentComplete,
  }) async {
    await _logEvent(AnalyticsEvent(
      name: 'goal_progress',
      timestamp: DateTime.now(),
      properties: {
        'percent_bucket': _getPercentBucket(percentComplete),
      },
    ));
  }

  /// Log reality check message viewed
  Future<void> logRealityCheckViewed({
    required String messageType, // 'low', 'medium', 'high', 'extreme'
    required double hoursWasted,
  }) async {
    await _logEvent(AnalyticsEvent(
      name: 'reality_check_viewed',
      timestamp: DateTime.now(),
      properties: {
        'message_type': messageType,
        'hours_bucket': _getHoursBucket(hoursWasted),
      },
    ));
  }

  // ============ ERROR TRACKING ============

  /// Log error
  Future<void> logError({
    required String errorType,
    String? errorMessage,
  }) async {
    await _logEvent(AnalyticsEvent(
      name: 'error',
      timestamp: DateTime.now(),
      properties: {
        'error_type': errorType,
        if (errorMessage != null) 'error_message': errorMessage,
      },
    ));
  }

  // ============ INTERNAL HELPERS ============

  Future<void> _logEvent(AnalyticsEvent event) async {
    _eventQueue.add(event.copyWith(
      properties: {
        ...event.properties,
        'session_id': _sessionId,
      },
    ));

    if (kDebugMode) {
      debugPrint('📊 Analytics: ${event.name} - ${event.properties}');
    }
  }

  Future<void> _flushEvents() async {
    if (_eventQueue.isEmpty) return;

    // In production, send to Firebase/Mixpanel/etc.
    // For now, just clear the queue
    final events = List<AnalyticsEvent>.from(_eventQueue);
    _eventQueue.clear();

    if (kDebugMode) {
      debugPrint('📊 Flushing ${events.length} analytics events');
    }

    // TODO: Send to backend
    // await _sendToBackend(events);
  }

  String _getDurationBucket(int minutes) {
    if (minutes < 15) return '0-15';
    if (minutes < 30) return '15-30';
    if (minutes < 60) return '30-60';
    if (minutes < 120) return '60-120';
    return '120+';
  }

  String _getHoursBucket(double hours) {
    if (hours < 2) return '0-2';
    if (hours < 5) return '2-5';
    if (hours < 10) return '5-10';
    if (hours < 20) return '10-20';
    return '20+';
  }

  String _getPercentBucket(double percent) {
    if (percent < 25) return '0-25';
    if (percent < 50) return '25-50';
    if (percent < 75) return '50-75';
    return '75-100';
  }
}

/// Analytics event model
class AnalyticsEvent {
  final String name;
  final DateTime timestamp;
  final Map<String, dynamic> properties;

  AnalyticsEvent({
    required this.name,
    required this.timestamp,
    this.properties = const {},
  });

  AnalyticsEvent copyWith({
    String? name,
    DateTime? timestamp,
    Map<String, dynamic>? properties,
  }) {
    return AnalyticsEvent(
      name: name ?? this.name,
      timestamp: timestamp ?? this.timestamp,
      properties: properties ?? this.properties,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'timestamp': timestamp.toIso8601String(),
      'properties': properties,
    };
  }
}

/// Event schema documentation
/// 
/// SESSION EVENTS:
/// - session_start: User opens app
/// - session_end: User closes app
///   - duration_seconds: Total session time
///   - screen_views: Number of screens viewed
/// 
/// SCREEN EVENTS:
/// - screen_view: User views a screen
///   - screen_name: Name of the screen
/// 
/// ACTION EVENTS:
/// - activity_logged: User logs an activity
///   - category: App category (Social Media, Streaming, etc.)
///   - duration_bucket: Time range (0-15, 15-30, 30-60, 60-120, 120+)
///   - is_productive: Boolean
/// 
/// - calendar_day_selected: User taps a day
///   - has_data: Boolean if day has logged data
/// 
/// - calendar_navigation: User navigates months
///   - direction: 'previous' or 'next'
/// 
/// - app_selected: User selects an app to log
///   - category: App category
/// 
/// - duration_changed: User changes duration
///   - duration_bucket: Time range
///   - method: 'preset' or 'slider'
/// 
/// ENGAGEMENT EVENTS:
/// - streak_milestone: User hits a logging streak
///   - days: Number of consecutive days
/// 
/// - goal_progress: Weekly goal progress
///   - percent_bucket: Progress range (0-25, 25-50, 50-75, 75-100)
/// 
/// - reality_check_viewed: User sees reality check message
///   - message_type: low/medium/high/extreme
///   - hours_bucket: Wasted hours range
/// 
/// ERROR EVENTS:
/// - error: An error occurred
///   - error_type: Type of error
///   - error_message: Optional message




