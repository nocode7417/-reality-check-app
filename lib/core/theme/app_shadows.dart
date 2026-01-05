import 'package:flutter/material.dart';

/// Premium iOS-Style Shadow System
/// Layered shadows for depth and elegance
class AppShadows {
  AppShadows._();

  // ============ BOX SHADOWS ============

  /// Subtle shadow - for minor elevation
  static List<BoxShadow> get sm => [
        BoxShadow(
          offset: const Offset(0, 1),
          blurRadius: 2,
          color: Colors.black.withOpacity(0.04),
        ),
      ];

  /// Medium shadow - for cards
  static List<BoxShadow> get md => [
        BoxShadow(
          offset: const Offset(0, 2),
          blurRadius: 8,
          color: Colors.black.withOpacity(0.04),
        ),
        BoxShadow(
          offset: const Offset(0, 4),
          blurRadius: 16,
          color: Colors.black.withOpacity(0.04),
        ),
      ];

  /// Large shadow - for elevated cards
  static List<BoxShadow> get lg => [
        BoxShadow(
          offset: const Offset(0, 4),
          blurRadius: 12,
          color: Colors.black.withOpacity(0.05),
        ),
        BoxShadow(
          offset: const Offset(0, 8),
          blurRadius: 32,
          color: Colors.black.withOpacity(0.08),
        ),
      ];

  /// Extra large shadow - for modals/overlays
  static List<BoxShadow> get xl => [
        BoxShadow(
          offset: const Offset(0, 8),
          blurRadius: 24,
          color: Colors.black.withOpacity(0.06),
        ),
        BoxShadow(
          offset: const Offset(0, 16),
          blurRadius: 48,
          color: Colors.black.withOpacity(0.1),
        ),
      ];

  /// Glow shadow - for accent elements
  static List<BoxShadow> get glow => [
        BoxShadow(
          offset: Offset.zero,
          blurRadius: 0,
          spreadRadius: 4,
          color: const Color(0xFFFF3B30).withOpacity(0.12),
        ),
      ];

  /// Green glow shadow - for productive elements
  static List<BoxShadow> get glowGreen => [
        BoxShadow(
          offset: Offset.zero,
          blurRadius: 0,
          spreadRadius: 4,
          color: const Color(0xFF34C759).withOpacity(0.12),
        ),
      ];

  /// Button shadow - for primary buttons
  static List<BoxShadow> get button => [
        BoxShadow(
          offset: const Offset(0, 4),
          blurRadius: 12,
          color: const Color(0xFFFF3B30).withOpacity(0.25),
        ),
        BoxShadow(
          offset: const Offset(0, 8),
          blurRadius: 24,
          color: const Color(0xFFFF3B30).withOpacity(0.15),
        ),
      ];

  /// Main nav button shadow
  static List<BoxShadow> get navButton => [
        BoxShadow(
          offset: const Offset(0, 4),
          blurRadius: 12,
          color: const Color(0xFFFF3B30).withOpacity(0.3),
        ),
        BoxShadow(
          offset: const Offset(0, 8),
          blurRadius: 24,
          color: const Color(0xFFFF3B30).withOpacity(0.2),
        ),
      ];

  /// Inner shadow effect
  static List<BoxShadow> get inner => [
        BoxShadow(
          offset: const Offset(0, 2),
          blurRadius: 4,
          color: Colors.black.withOpacity(0.04),
          blurStyle: BlurStyle.inner,
        ),
      ];

  /// Selected day shadow
  static List<BoxShadow> get selectedDay => [
        BoxShadow(
          offset: Offset.zero,
          blurRadius: 0,
          spreadRadius: 2,
          color: Colors.white,
        ),
        BoxShadow(
          offset: Offset.zero,
          blurRadius: 0,
          spreadRadius: 4,
          color: const Color(0xFFFF3B30),
        ),
        BoxShadow(
          offset: const Offset(0, 4),
          blurRadius: 12,
          color: Colors.black.withOpacity(0.15),
        ),
      ];
}




