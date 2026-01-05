import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Premium iOS-Style Typography System
/// Uses Inter (via Google Fonts) mapping to Apple's type scale
class AppTypography {
  AppTypography._();

  // ============ FONT SIZES ============
  static const double sizeXs = 11.0;
  static const double sizeSm = 13.0;
  static const double sizeBase = 15.0;
  static const double sizeMd = 17.0;
  static const double sizeLg = 20.0;
  static const double sizeXl = 28.0;
  static const double sizeXxl = 34.0;
  static const double sizeHero = 48.0;

  // ============ FONT WEIGHTS ============
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // ============ LETTER SPACING ============
  static const double trackingTight = -0.02;
  static const double trackingNormal = -0.01;
  static const double trackingWide = 0.02;

  // ============ LINE HEIGHTS ============
  static const double leadingNone = 1.0;
  static const double leadingTight = 1.2;
  static const double leadingSnug = 1.35;
  static const double leadingNormal = 1.5;
  static const double leadingRelaxed = 1.6;

  // ============ TEXT STYLES ============

  /// Hero stat value - 48px bold
  static TextStyle hero({Color? color}) => GoogleFonts.inter(
        fontSize: sizeHero,
        fontWeight: bold,
        height: leadingTight,
        letterSpacing: -0.03,
        color: color ?? AppColors.textPrimary,
      );

  /// Page title - 34px bold
  static TextStyle title({Color? color}) => GoogleFonts.inter(
        fontSize: sizeXxl,
        fontWeight: bold,
        height: leadingTight,
        letterSpacing: trackingTight,
        color: color ?? AppColors.textPrimary,
      );

  /// Section heading - 28px semibold
  static TextStyle heading({Color? color}) => GoogleFonts.inter(
        fontSize: sizeXl,
        fontWeight: semibold,
        height: leadingTight,
        letterSpacing: trackingTight,
        color: color ?? AppColors.textPrimary,
      );

  /// Subheading - 20px semibold
  static TextStyle subheading({Color? color}) => GoogleFonts.inter(
        fontSize: sizeLg,
        fontWeight: semibold,
        height: leadingSnug,
        letterSpacing: trackingNormal,
        color: color ?? AppColors.textPrimary,
      );

  /// Section title - 17px semibold
  static TextStyle sectionTitle({Color? color}) => GoogleFonts.inter(
        fontSize: sizeMd,
        fontWeight: semibold,
        height: leadingSnug,
        letterSpacing: trackingNormal,
        color: color ?? AppColors.textPrimary,
      );

  /// Body text - 15px regular
  static TextStyle body({Color? color}) => GoogleFonts.inter(
        fontSize: sizeBase,
        fontWeight: regular,
        height: leadingNormal,
        letterSpacing: trackingNormal,
        color: color ?? AppColors.textSecondary,
      );

  /// Button text - 17px semibold
  static TextStyle button({Color? color}) => GoogleFonts.inter(
        fontSize: sizeMd,
        fontWeight: semibold,
        height: leadingNone,
        letterSpacing: trackingNormal,
        color: color ?? Colors.white,
      );

  /// Caption - 13px medium
  static TextStyle caption({Color? color}) => GoogleFonts.inter(
        fontSize: sizeSm,
        fontWeight: medium,
        height: leadingNormal,
        color: color ?? AppColors.textTertiary,
      );

  /// Small label - 11px medium
  static TextStyle label({Color? color}) => GoogleFonts.inter(
        fontSize: sizeXs,
        fontWeight: medium,
        height: leadingNormal,
        letterSpacing: trackingWide,
        color: color ?? AppColors.textMuted,
      );

  /// Eyebrow text - 13px semibold uppercase
  static TextStyle eyebrow({Color? color}) => GoogleFonts.inter(
        fontSize: sizeSm,
        fontWeight: semibold,
        height: leadingNormal,
        letterSpacing: 0.02,
        color: color ?? AppColors.accent,
      );

  /// Stat value - 26px semibold
  static TextStyle statValue({Color? color}) => GoogleFonts.inter(
        fontSize: 26,
        fontWeight: semibold,
        height: leadingTight,
        letterSpacing: trackingTight,
        color: color ?? AppColors.textPrimary,
      );

  /// Stat value small - 22px bold
  static TextStyle statValueSmall({Color? color}) => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: bold,
        height: leadingTight,
        letterSpacing: trackingTight,
        color: color ?? AppColors.textPrimary,
      );

  /// Comparison value - 20px bold
  static TextStyle comparisonValue({Color? color}) => GoogleFonts.inter(
        fontSize: sizeLg,
        fontWeight: bold,
        height: leadingTight,
        letterSpacing: trackingTight,
        color: color ?? AppColors.accent,
      );

  /// Nav label - 11px medium
  static TextStyle navLabel({Color? color}) => GoogleFonts.inter(
        fontSize: sizeXs,
        fontWeight: medium,
        letterSpacing: 0.01,
        color: color ?? AppColors.textMuted,
      );
}




