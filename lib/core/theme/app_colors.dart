import 'package:flutter/material.dart';

/// Premium iOS-Style Color System
/// Matches the web app's design system exactly
class AppColors {
  AppColors._();

  // ============ BACKGROUNDS ============
  static const Color bgPrimary = Color(0xFFFFFFFF);
  static const Color bgSecondary = Color(0xFFF8F9FA);
  static const Color bgTertiary = Color(0xFFF1F3F4);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgCardHover = Color(0xFFFAFBFC);

  // ============ ACCENT - iOS Red ============
  static const Color accent = Color(0xFFFF3B30);
  static const Color accentLight = Color(0xFFFF6961);
  static const Color accentDark = Color(0xFFD70015);
  static const Color accentSoft = Color(0x14FF3B30); // 8% opacity

  // ============ PRODUCTIVE - iOS Green ============
  static const Color productive = Color(0xFF34C759);
  static const Color productiveLight = Color(0xFF5DD879);
  static const Color productiveDark = Color(0xFF248A3D);
  static const Color productiveSoft = Color(0x1434C759); // 8% opacity

  // ============ TEXT ============
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF636366);
  static const Color textTertiary = Color(0xFF8E8E93);
  static const Color textMuted = Color(0xFF8E8E93); // Improved contrast (was #AEAEB2)

  // ============ WASTED TIME GRADIENT ============
  static const Color wastedLight = Color(0xFFFFCDD2);
  static const Color wastedMedium = Color(0xFFFF3B30);
  static const Color wastedDark = Color(0xFFC62828);

  // ============ NEUTRAL ============
  static const Color neutral = Color(0xFFF2F2F7);
  static const Color neutralLight = Color(0xFFE5E5EA);

  // ============ BORDERS ============
  static const Color border = Color(0xFFE5E5EA);
  static const Color borderLight = Color(0xFFF2F2F7);

  // ============ OVERLAYS & GLASS ============
  static const Color overlay = Color(0x4D000000); // 30% opacity
  static const Color glass = Color(0xB8FFFFFF); // 72% opacity
  static const Color glassStroke = Color(0x80FFFFFF); // 50% opacity

  // ============ CALENDAR INTENSITY COLORS ============
  static const Color intensityNone = Color(0xFFF2F2F7);
  static const Color intensityLow = Color(0xFFFECACA);
  static const Color intensityMedium = Color(0xFFFCA5A5);
  static const Color intensityHigh = Color(0xFFF87171);
  static const Color intensityExtreme = Color(0xFFFF3B30);

  // ============ GRADIENTS ============
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentDark],
  );

  static const LinearGradient productiveGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [productive, productiveDark],
  );

  static const LinearGradient cardAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF5F5), Color(0xFFFFFFFF)],
  );

  static const LinearGradient cardProductiveGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF0FDF4), Color(0xFFFFFFFF)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF5F5), Color(0xFFFFF0F0), Color(0xFFFFFFFF)],
  );

  /// Get intensity color based on hours wasted (0-1 scale)
  static Color getIntensityColor(double intensity) {
    if (intensity <= 0) return intensityNone;
    if (intensity < 0.25) return intensityLow;
    if (intensity < 0.5) return intensityMedium;
    if (intensity < 0.75) return intensityHigh;
    return intensityExtreme;
  }
}




