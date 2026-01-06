import '../models/models.dart';

/// Calculation service for earnings, skills, and reality-check messages
class CalculationService {
  // ============ WAGE RATES ============
  static const Map<String, double> wageRates = {
    'minimumWage': 10,
    'retail': 14, // avg of 12-16
    'foodService': 12.5, // avg of 10-15
    'tutoring': 20, // avg of 15-25
    'customerService': 15, // avg of 12-18
    'contentWriting': 22.5, // avg of 15-30
    'graphicDesign': 27.5, // avg of 20-35
    'videoEditing': 30, // avg of 20-40
    'webDevelopment': 32.5, // avg of 25-40
    'socialMediaManagement': 20, // avg of 15-25
  };

  // ============ LEARNING MILESTONES (hours) ============
  static const Map<String, Map<String, int>> learningMilestones = {
    'language': {
      'basic': 100,
      'conversational': 300,
      'fluent': 600,
    },
    'instrument': {
      'beginner': 100,
      'basic': 150,
      'intermediate': 300,
    },
    'coding': {
      'fundamentals': 100,
      'jobReady': 200,
      'proficient': 500,
    },
    'fitness': {
      'habit': 50,
      'transformation': 100,
      'athletic': 300,
    },
  };

  // ============ EARNINGS CALCULATION ============

  /// Calculate potential earnings from wasted time
  static EarningsResult calculateEarnings(double hours, {String rateType = 'minimumWage'}) {
    final rate = wageRates[rateType] ?? wageRates['minimumWage']!;
    
    return EarningsResult(
      min: (hours * rate * 0.8).round(), // Conservative (breaks, learning)
      max: (hours * rate * 0.95).round(), // Realistic max
      rateUsed: rate,
    );
  }

  /// Calculate earnings at minimum wage
  static int calculateMinWageEarnings(double hours) {
    return (hours * 10).round(); // $10/hr baseline
  }

  /// Calculate freelance coding earnings
  static EarningsResult calculateFreelanceEarnings(double hours) {
    return EarningsResult(
      min: (hours * 25).round(),
      max: (hours * 40).round(),
      rateUsed: 32.5,
    );
  }

  // ============ SKILL PROGRESS ============

  /// Calculate skill progress equivalent
  static SkillProgress calculateSkillProgress(double hours, String skill) {
    final milestones = learningMilestones[skill];
    if (milestones == null) {
      return SkillProgress(
        progressPercent: 0,
        currentLevel: null,
        nextLevel: null,
        hoursToNext: 0,
        daysEquivalent: hours / 2,
      );
    }

    String? currentLevel;
    String? nextLevel;
    int progressPercent = 0;
    int hoursToNext = 0;
    int prevHours = 0;

    for (final entry in milestones.entries) {
      if (hours >= entry.value) {
        currentLevel = entry.key;
        prevHours = entry.value;
      } else {
        nextLevel = entry.key;
        hoursToNext = entry.value - hours.toInt();
        progressPercent = ((hours - prevHours) / (entry.value - prevHours) * 100).round();
        break;
      }
    }

    // If all milestones achieved
    if (nextLevel == null && currentLevel != null) {
      progressPercent = 100;
    }

    return SkillProgress(
      progressPercent: progressPercent.clamp(0, 100),
      currentLevel: currentLevel,
      nextLevel: nextLevel,
      hoursToNext: hoursToNext.clamp(0, 1000),
      daysEquivalent: hours / 2, // 2 hours practice per day
    );
  }

  /// Calculate learning days equivalent
  static double calculateLearningDays(double hours, {double dailyPractice = 2}) {
    return hours / dailyPractice;
  }

  // ============ REALITY CHECK MESSAGES ============

  /// Get supportive reality-check message based on wasted hours
  static String getRealityCheckMessage(double wastedHours, {String context = 'week'}) {
    final category = _getMessageCategory(wastedHours, context);
    final messages = _realityMessages[category]!;
    
    // Use hash of hours to get consistent but varied message
    final index = (wastedHours * 10).round() % messages.length;
    return messages[index];
  }

  static String _getMessageCategory(double hours, String context) {
    if (context == 'week') {
      if (hours < 10) return 'low';
      if (hours < 25) return 'medium';
      if (hours < 40) return 'high';
      return 'extreme';
    } else {
      // Daily context
      if (hours < 2) return 'low';
      if (hours < 4) return 'medium';
      if (hours < 6) return 'high';
      return 'extreme';
    }
  }

  static const Map<String, List<String>> _realityMessages = {
    'low': [
      "You're doing better than most. Keep building momentum.",
      'Solid control over your time. Small improvements compound.',
      'Good balance. What could you do with even one more hour?',
    ],
    'medium': [
      "You're not alone—most people waste 28hrs/week. But you can do better.",
      'That time adds up. Imagine redirecting just half of it.',
      "Progress isn't about perfection. Start with one less hour tomorrow.",
    ],
    'high': [
      'This is a lot, but awareness is the first step to change.',
      'Every hour you reclaim is an investment in your future self.',
      "It's hard, but here's what's possible if you start small.",
    ],
    'extreme': [
      'This is a wake-up call. Your time is your most valuable asset.',
      "The good news? There's a lot of room for improvement here.",
      "Start with 30 minutes. That's all. Build from there.",
    ],
  };

  // ============ FORMATTING ============

  /// Format hours to readable string
  static String formatHours(double hours) {
    if (hours < 1) {
      return '${(hours * 60).round()}m';
    }
    if (hours < 24) {
      final h = hours.floor();
      final m = ((hours - h) * 60).round();
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    final days = (hours / 24).floor();
    final h = (hours % 24).round();
    return h > 0 ? '${days}d ${h}h' : '${days}d';
  }

  /// Format currency
  static String formatCurrency(int amount) {
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}k';
    }
    return '\$$amount';
  }

  /// Get intensity color value (0-1) for calendar
  static double getWastedIntensity(double hoursWasted, {double maxExpected = 8}) {
    return (hoursWasted / maxExpected).clamp(0.0, 1.0);
  }

  // ============ COMPARISONS ============

  /// Calculate weekly comparison
  static WeeklyComparison calculateWeeklyComparison(double currentWeek, double previousWeek) {
    return WeeklyComparison.calculate(currentWeek, previousWeek);
  }

  /// Get featured comparison cards data
  static List<ComparisonCard> getFeaturedComparisons(double wastedHours) {
    return [
      ComparisonCard(
        icon: '💰',
        title: 'Minimum Wage',
        value: '\$${(wastedHours * 10).round()}',
        subtitle: 'at \$10/hr baseline',
        colorHex: '#FF3B30',
      ),
      ComparisonCard(
        icon: '💻',
        title: 'Freelance Coding',
        value: '\$${(wastedHours * 25).round()}–\$${(wastedHours * 40).round()}',
        subtitle: 'beginner web dev rates',
        colorHex: '#34C759',
      ),
      ComparisonCard(
        icon: '📚',
        title: 'Learning Progress',
        value: '${(wastedHours / 2).round()} days',
        subtitle: '@ 2hrs practice/day',
        colorHex: '#007AFF',
      ),
    ];
  }
}

/// Earnings calculation result
class EarningsResult {
  final int min;
  final int max;
  final double rateUsed;

  EarningsResult({
    required this.min,
    required this.max,
    required this.rateUsed,
  });

  String get formatted => '\$$min–\$$max';
}

/// Skill progress result
class SkillProgress {
  final int progressPercent;
  final String? currentLevel;
  final String? nextLevel;
  final int hoursToNext;
  final double daysEquivalent;

  SkillProgress({
    required this.progressPercent,
    required this.currentLevel,
    required this.nextLevel,
    required this.hoursToNext,
    required this.daysEquivalent,
  });
}

/// Comparison card data
class ComparisonCard {
  final String icon;
  final String title;
  final String value;
  final String subtitle;
  final String colorHex;

  ComparisonCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.colorHex,
  });
}




