import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dimensions.dart';

const bool useMaterial3 = true;

const Color kSeedColorLight = Color(0xFF5D4BDB);
const Color kSeedColorDark = Color(0xFF7B68EE);
const Color kSecondaryColorLight = Color(0xFF3F6AEC);
const Color kSecondaryColorDark = Color(0xFF5C8CF7);
const Color kTertiaryColorLight = Color(0xFFF06B45);
const Color kTertiaryColorDark = Color(0xFFFF8F6B);
const Color kSurfaceDark = Color(0xFF3C3A45);

bool get isMobile =>
    defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;

// Función extraída para reducir código duplicado y mejorar claridad.
ColorScheme _defaultColorScheme({
  required bool isDark,
  required Color seedColor,
  required Color secondaryColor,
  required Color tertiaryColor,
  Color? surfaceContainerHighest,
}) =>
    ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: isDark ? Brightness.dark : Brightness.light,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      surfaceContainerHighest: surfaceContainerHighest,
    );

ThemeData lightTheme({ColorScheme? dynamicScheme}) => _customizeTheme(
      ThemeData(
        colorScheme: dynamicScheme ??
            _defaultColorScheme(
              isDark: false,
              seedColor: kSeedColorLight,
              secondaryColor: kSecondaryColorLight,
              tertiaryColor: kTertiaryColorLight,
            ),
        useMaterial3: useMaterial3,
      ),
      isDark: false,
    );

ThemeData darkTheme({ColorScheme? dynamicScheme}) => _customizeTheme(
      ThemeData(
        colorScheme: dynamicScheme ??
            _defaultColorScheme(
              isDark: true,
              seedColor: kSeedColorDark,
              secondaryColor: kSecondaryColorDark,
              tertiaryColor: kTertiaryColorDark,
              surfaceContainerHighest: kSurfaceDark,
            ),
        useMaterial3: useMaterial3,
      ),
      isDark: true,
    );

ThemeData get dynamicTheme {
  final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
  return brightness == Brightness.dark ? darkTheme() : lightTheme();
}

ThemeData _customizeTheme(ThemeData theme, {required bool isDark}) {
  return theme.copyWith(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    splashFactory: InkSparkle.splashFactory,
    cardTheme: CardTheme(
      color: isDark
          ? theme.colorScheme.surfaceContainerHighest
          : theme.colorScheme.surfaceContainerHigh,
      elevation: isDark ? AppDimensions.elevationMedium : AppDimensions.elevationSmall,
      shadowColor: theme.colorScheme.shadow.withAlpha(isDark ? 140 : 100),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing28, vertical: AppDimensions.spacing16),
        elevation: AppDimensions.elevationSmall,
        shadowColor: theme.colorScheme.primary.withAlpha(120),
        textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: AppDimensions.textMedium),
      ),
    ),
  );
}
