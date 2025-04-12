import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';

bool get useMaterial3 => true;

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
      elevation: isDark ? 3.0 : 2.0,
      shadowColor: cs.shadow.withAlpha(isDark ? 120 : 80),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        elevation: 2,
        shadowColor: cs.primary.withAlpha(100),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 1.5,
        backgroundColor: cs.surfaceContainerHigh.withAlpha(220),
        foregroundColor: cs.primary,
        shadowColor: cs.shadow.withAlpha(50),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: BorderSide(width: isMobile ? 2.0 : 1.5, color: cs.primary.withAlpha(180)),
        foregroundColor: cs.primary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerLowest.withAlpha(230),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: cs.outline, width: isMobile ? 1.5 : 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: cs.outline.withAlpha(180), width: isMobile ? 2 : 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: cs.primary, width: isMobile ? 2.5 : 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      floatingLabelStyle: TextStyle(
        color: cs.primary,
        fontWeight: FontWeight.w500,
      ),
      prefixIconColor: cs.primary.withAlpha(220),
      suffixIconColor: cs.onSurfaceVariant,
    ),
    textTheme: tt.copyWith(
      displayLarge: tt.displayLarge?.copyWith(fontWeight: FontWeight.w600),
      headlineMedium: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
      titleLarge: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: tt.bodyLarge?.copyWith(height: 1.5),
      labelLarge: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    ),
    appBarTheme: theme.appBarTheme.copyWith(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1.5,
      backgroundColor: cs.surface.withAlpha(240),
      titleTextStyle: tt.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: cs.onSurface,
      ),
      iconTheme: IconThemeData(
        color: cs.onSurface,
        size: 24,
      ),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      iconColor: cs.primary,
      titleTextStyle: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
    ),
    dividerTheme: DividerThemeData(
      thickness: 0.8,
      space: 32,
      color: cs.outlineVariant.withAlpha(150),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? cs.onPrimary : cs.outline,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? cs.primary : cs.surfaceContainerHighest,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: BorderSide(color: cs.outline, width: 1.5), // Borde en checkboxes
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? cs.primary : cs.outline,
      ),
    ),
    iconTheme: IconThemeData(
      size: 24,
      color: cs.onSurface,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      extendedPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    ),
    sliderTheme: SliderThemeData(
      trackHeight: 4,
      activeTrackColor: cs.primary,
      inactiveTrackColor: cs.surfaceContainerHighest,
      thumbColor: cs.primary,
      overlayColor: cs.primary.withAlpha(30),
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
    ),
  );
}
