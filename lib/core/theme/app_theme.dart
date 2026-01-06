import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// Main theme configuration for Reality Check app
class AppTheme {
  AppTheme._();

  /// Light theme (iOS-style)
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Colors
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        onPrimary: Colors.white,
        secondary: AppColors.productive,
        onSecondary: Colors.white,
        surface: AppColors.bgCard,
        onSurface: AppColors.textPrimary,
        error: AppColors.accent,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.bgSecondary,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Cards
      cardTheme: const CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusXl,
        ),
        margin: EdgeInsets.zero,
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space5,
            vertical: AppSpacing.space4,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusLg,
          ),
          textStyle: AppTypography.button(),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: AppTypography.button(color: AppColors.accent),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral,
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide(color: AppColors.accent, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space3,
        ),
      ),

      // Slider
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: AppColors.neutralLight,
        thumbColor: Colors.white,
        overlayColor: AppColors.accentSoft,
        trackHeight: 6,
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: 12,
          elevation: 4,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 0,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTypography.title(),
        displayMedium: AppTypography.heading(),
        displaySmall: AppTypography.subheading(),
        headlineMedium: AppTypography.sectionTitle(),
        titleLarge: AppTypography.sectionTitle(),
        titleMedium: AppTypography.body(),
        bodyLarge: AppTypography.body(),
        bodyMedium: AppTypography.caption(),
        bodySmall: AppTypography.label(),
        labelLarge: AppTypography.button(),
        labelMedium: AppTypography.caption(),
        labelSmall: AppTypography.label(),
      ),

      // Splash/Highlight
      splashColor: AppColors.accentSoft,
      highlightColor: Colors.transparent,
      splashFactory: InkRipple.splashFactory,
    );
  }

  /// Dark theme (iOS-style)
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Colors
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        onPrimary: Colors.white,
        secondary: AppColors.productive,
        onSecondary: Colors.white,
        surface: Color(0xFF1C1C1E),
        onSurface: Color(0xFFF2F2F7),
        error: AppColors.accent,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: const Color(0xFF000000),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF2F2F7),
        ),
        iconTheme: IconThemeData(color: Color(0xFFF2F2F7)),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: Color(0xFF8E8E93),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Cards
      cardTheme: const CardThemeData(
        color: Color(0xFF1C1C1E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusXl,
        ),
        margin: EdgeInsets.zero,
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space5,
            vertical: AppSpacing.space4,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusLg,
          ),
          textStyle: AppTypography.button(),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: AppTypography.button(color: AppColors.accent),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF2C2C2E),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide(color: AppColors.accent, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space3,
        ),
      ),

      // Slider
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: Color(0xFF3A3A3C),
        thumbColor: Colors.white,
        overlayColor: AppColors.accentSoft,
        trackHeight: 6,
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: 12,
          elevation: 4,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFF3A3A3C),
        thickness: 1,
        space: 0,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTypography.title(color: const Color(0xFFF2F2F7)),
        displayMedium: AppTypography.heading(color: const Color(0xFFF2F2F7)),
        displaySmall: AppTypography.subheading(color: const Color(0xFFF2F2F7)),
        headlineMedium: AppTypography.sectionTitle(color: const Color(0xFFF2F2F7)),
        titleLarge: AppTypography.sectionTitle(color: const Color(0xFFF2F2F7)),
        titleMedium: AppTypography.body(color: const Color(0xFF8E8E93)),
        bodyLarge: AppTypography.body(color: const Color(0xFF8E8E93)),
        bodyMedium: AppTypography.caption(color: const Color(0xFF636366)),
        bodySmall: AppTypography.label(color: const Color(0xFF636366)),
        labelLarge: AppTypography.button(),
        labelMedium: AppTypography.caption(color: const Color(0xFF636366)),
        labelSmall: AppTypography.label(color: const Color(0xFF636366)),
      ),

      // Splash/Highlight
      splashColor: AppColors.accentSoft,
      highlightColor: Colors.transparent,
      splashFactory: InkRipple.splashFactory,
    );
  }
}




