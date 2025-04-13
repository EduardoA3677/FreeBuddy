import 'package:flutter/material.dart';

/// Clase que contiene las dimensiones estándar para mantener consistencia en la UI
class AppDimensions {
  // Espaciado
  static const double spacing2 = 2.0;
  static const double spacing3 = 3.0;
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing10 = 10.0;
  static const double spacing12 = 12.0;
  static const double spacing14 = 14.0;
  static const double spacing16 = 16.0;
  static const double spacing18 = 18.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing28 = 28.0;
  static const double spacing30 = 30.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing56 = 56.0;
  static const double spacing64 = 64.0;

  // Radios de bordes
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 20.0;
  static const double radiusExtraLarge = 28.0;
  static const double radiusCircular = 50.0;

  // Elevaciones
  static const double elevationNone = 0.0;
  static const double elevationXSmall = 1.0;
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;
  static const double elevationXLarge = 12.0;

  // Tamaños de texto
  static const double textXSmall = 12.0;
  static const double textSmall = 14.0;
  static const double textMedium = 16.0;
  static const double textLarge = 18.0;
  static const double textXLarge = 20.0;
  static const double textXXLarge = 24.0;
  static const double textHeading = 28.0;

  static const double radiusXSmall = 6.0;

  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Dimensiones específicas para widgets
  static const double appBarHeight = 56.0;
  static const double buttonHeight = 48.0;
  static const double cardMinHeight = 80.0;
  static const double cardContentPadding = 16.0;
  static const double inputFieldHeight = 56.0;
  static const double bottomNavBarHeight = 80.0;

  // Dimensiones responsivas
  static double getResponsiveWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }

  static double getResponsiveHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * (percentage / 100);
  }

  // Paddings comunes
  static const EdgeInsets paddingSmall = EdgeInsets.all(spacing8);
  static const EdgeInsets paddingMedium = EdgeInsets.all(spacing16);
  static const EdgeInsets paddingLarge = EdgeInsets.all(spacing24);

  static const EdgeInsets paddingHorizontalSmall = EdgeInsets.symmetric(horizontal: spacing8);
  static const EdgeInsets paddingHorizontalMedium = EdgeInsets.symmetric(horizontal: spacing16);
  static const EdgeInsets paddingHorizontalLarge = EdgeInsets.symmetric(horizontal: spacing24);

  static const EdgeInsets paddingVerticalSmall = EdgeInsets.symmetric(vertical: spacing8);
  static const EdgeInsets paddingVerticalMedium = EdgeInsets.symmetric(vertical: spacing16);
  static const EdgeInsets paddingVerticalLarge = EdgeInsets.symmetric(vertical: spacing24);

  // Paddings específicos para componentes comunes
  static const EdgeInsets cardPadding = EdgeInsets.all(spacing16);
  static const EdgeInsets buttonPadding =
      EdgeInsets.symmetric(horizontal: spacing24, vertical: spacing12);
  static const EdgeInsets listTilePadding =
      EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing12);
}
