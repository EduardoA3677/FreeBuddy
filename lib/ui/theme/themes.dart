import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';

import 'dimensions.dart';

// Siempre usamos Material 3
const bool useMaterial3 = true;

// Comprueba si estamos en una plataforma móvil
bool get isMobile =>
    defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;

/// Tema claro basado en Material You con esquema dinámico opcional
ThemeData lightTheme({ColorScheme? dynamicScheme}) => _customize(
      ThemeData(
        colorScheme: dynamicScheme ??
            ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
              brightness: Brightness.light,
            ),
        useMaterial3: true,
      ),
      isDark: false,
    );

/// Tema oscuro basado en Material You con esquema dinámico opcional
ThemeData darkTheme({ColorScheme? dynamicScheme}) => _customize(
      ThemeData(
        colorScheme: dynamicScheme ??
            ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4),
              brightness: Brightness.dark,
            ),
        useMaterial3: true,
      ),
      isDark: true,
    );

/// Devuelve el tema dinámico según el sistema
ThemeData get dynamicTheme {
  final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
  return brightness == Brightness.dark ? darkTheme() : lightTheme();
}

/// Aplica personalizaciones al tema
ThemeData _customize(ThemeData theme, {required bool isDark}) {
  final tt = theme.textTheme;
  final cs = theme.colorScheme;

  return theme.copyWith(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    splashFactory: InkSparkle.splashFactory,
    cardTheme: CardTheme(
      color: isDark ? cs.surfaceContainerHighest : cs.surfaceContainerHighest, // Ajuste de colores
      elevation: isDark ? AppDimensions.elevationMedium : AppDimensions.elevationSmall,
      shadowColor: cs.shadow.withAlpha(isDark ? 120 : 80),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero, // Eliminación de márgenes para evitar movimiento
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing28, vertical: AppDimensions.spacing16),
        elevation: AppDimensions.elevationSmall,
        shadowColor: cs.primary.withAlpha(100),
        textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: AppDimensions.textMedium),
      ),
    ),
    // Continúan configuraciones adicionales...
  );
}
