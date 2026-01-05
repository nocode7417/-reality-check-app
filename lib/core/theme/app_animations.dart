import 'package:flutter/material.dart';

/// Premium iOS-Style Animation Constants
/// Smooth, natural, spring-physics based movements
class AppAnimations {
  AppAnimations._();

  // ============ DURATIONS ============
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration spring = Duration(milliseconds: 400);
  static const Duration springSmooth = Duration(milliseconds: 500);
  static const Duration bounce = Duration(milliseconds: 300);
  static const Duration fadeInDuration = Duration(milliseconds: 500);
  static const Duration stagger = Duration(milliseconds: 50);

  // ============ CURVES ============
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  
  /// iOS-style spring curve
  static const Curve springCurve = Curves.elasticOut;
  
  /// Smooth deceleration
  static const Curve decelerate = Cubic(0.23, 1, 0.32, 1);
  
  /// Spring with bounce
  static const Curve bounceCurve = Cubic(0.175, 0.885, 0.32, 1.275);
  
  /// Gentle spring
  static const Curve gentleSpring = Cubic(0.34, 1.56, 0.64, 1);

  // ============ TRANSFORM VALUES ============
  static const double fadeInUpOffset = 12.0;
  static const double hoverLift = -2.0;
  static const double pressScale = 0.97;
  static const double hoverScale = 1.02;
  static const double selectedScale = 1.1;

  // ============ STAGGER DELAYS ============
  static Duration staggerDelay(int index) {
    return Duration(milliseconds: 50 * index);
  }

  // ============ PAGE TRANSITIONS ============
  static SlideTransition slideFromRight(
    Animation<double> animation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: decelerate,
      )),
      child: child,
    );
  }

  static FadeTransition fadeIn(
    Animation<double> animation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: easeOut,
      ),
      child: child,
    );
  }
}

/// Extension for easy staggered animations
extension StaggeredAnimation on int {
  Duration get staggerDelay => AppAnimations.staggerDelay(this);
}




