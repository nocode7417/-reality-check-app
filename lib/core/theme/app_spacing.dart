import 'package:flutter/material.dart';

/// Premium iOS-Style Spacing System
/// Uses 4px base unit
class AppSpacing {
  AppSpacing._();

  // ============ SPACING SCALE ============
  static const double space0 = 0;
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space10 = 40;
  static const double space12 = 48;
  static const double space16 = 64;

  // ============ BORDER RADIUS ============
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusXxl = 28;
  static const double radiusFull = 9999;

  // ============ LAYOUT CONSTANTS ============
  static const double navHeight = 84;
  static const double maxWidth = 428; // iPhone 14 Pro Max
  static const double pageHorizontalPadding = 20;
  static const double pageTopPadding = 8;
  static const double navButtonElevation = 28;
  static const double navButtonLabelOffset = 24;
  static const double navButtonSize = 56;
  static const double navHorizontalPadding = 32;
  static const double navTopPadding = 12;
  static const double navBottomPadding = 16;

  // ============ EDGE INSETS ============
  static const EdgeInsets pagePadding = EdgeInsets.only(
    left: space5,
    right: space5,
    top: space2,
    bottom: navHeight + space6,
  );

  static const EdgeInsets cardPaddingSmall = EdgeInsets.all(space4);
  static const EdgeInsets cardPaddingMedium = EdgeInsets.all(space5);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(space6);
  static const EdgeInsets cardPaddingHero = EdgeInsets.symmetric(
    horizontal: space6,
    vertical: space8,
  );

  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(vertical: space3);

  // ============ BORDER RADIUS OBJECTS ============
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderRadiusXxl = BorderRadius.all(Radius.circular(radiusXxl));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(radiusFull));
}




