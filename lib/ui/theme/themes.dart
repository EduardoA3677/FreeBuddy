import 'package:flutter/material.dart';

// Material 3 está habilitado por defecto en versiones recientes de Flutter
bool get useMaterial3 => true;

/// Personaliza ambos temas (claro y oscuro) con un estilo más moderno y elegante
ThemeData _customize(ThemeData theme) {
  final tt = theme.textTheme;
  final colorScheme = theme.colorScheme;

  return theme.copyWith(
    // Tarjetas con bordes más suaves y sombras más sutiles
    cardTheme: CardTheme(
      elevation: 1.5,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
    ),

    // Botones principales con mayor énfasis visual
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 0.5,
        textStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0.3,
        ),
      ),
    ),

    // Botones secundarios con estilo más claro
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 0.5,
        backgroundColor: colorScheme.surfaceContainerHigh,
        foregroundColor: colorScheme.primary,
      ),
    ),

    // Botones terciarios con bordes más sutiles
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        side: BorderSide(width: 1.2, color: colorScheme.outline),
        foregroundColor: colorScheme.primary,
      ),
    ),

    // Input decorations más limpias
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),

    // Personalización avanzada de tipografía
    textTheme: tt.copyWith(
      // Display texts
      displayLarge: tt.displayLarge!.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      displayMedium: tt.displayMedium!.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.3,
      ),
      displaySmall: tt.displaySmall!.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.2,
      ),

      // Headlines
      headlineLarge: tt.headlineLarge!.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      headlineMedium: tt.headlineMedium!.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      headlineSmall: tt.headlineSmall!.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),

      // Titles
      titleLarge: tt.titleLarge!.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      titleMedium: tt.titleMedium!.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      titleSmall: tt.titleSmall!.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),

      // Body text
      bodyLarge: tt.bodyLarge!.copyWith(
        fontSize: 17,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      bodyMedium: tt.bodyMedium!.copyWith(
        fontSize: 15.5,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      bodySmall: tt.bodySmall!.copyWith(
        fontSize: 13.5,
        letterSpacing: 0.1,
        height: 1.4,
      ),

      // Labels
      labelLarge: tt.labelLarge!.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelMedium: tt.labelMedium!.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
      labelSmall: tt.labelSmall!.copyWith(
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
    ),

    // AppBar con estilo más moderno
    appBarTheme: theme.appBarTheme.copyWith(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1.5,
      backgroundColor: colorScheme.surface.withValues(alpha: 0.95),
      titleTextStyle: tt.titleLarge!.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: colorScheme.onSurface,
      ),
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),
    ),

    // Lista con diseños más espaciados y modernos
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      iconColor: colorScheme.primary,
      titleTextStyle: tt.bodyLarge!.copyWith(fontWeight: FontWeight.w500),
    ),

    // Divider más sutil
    dividerTheme: DividerThemeData(
      thickness: 0.8,
      space: 32,
      color: colorScheme.outlineVariant.withValues(alpha: 0.6),
    ),

    // Switches y Checkboxes con diseño más redondeado
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.onPrimary;
        }
        return colorScheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.surfaceContainerHighest;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.transparent;
        }
        return colorScheme.outline.withValues(alpha: 0.5);
      }),
    ),

    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: BorderSide(width: 1.5, color: colorScheme.outline),
    ),

    // Radio buttons con colores más prominentes
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.outline;
      }),
    ),

    // Iconos con tamaño uniforme
    iconTheme: IconThemeData(
      size: 24,
      color: colorScheme.onSurface,
    ),

    // Floating action button más elegante
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 2,
      focusElevation: 3,
      hoverElevation: 3,
      highlightElevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      extendedPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    ),

    // Sliders con diseño más distintivo
    sliderTheme: SliderThemeData(
      trackHeight: 4,
      activeTrackColor: colorScheme.primary,
      inactiveTrackColor: colorScheme.surfaceContainerHighest,
      thumbColor: colorScheme.primary,
      overlayColor: colorScheme.primary.withValues(alpha: 0.12),
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
    ),

    // Tabs con indicador más distintivo
    tabBarTheme: TabBarTheme(
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.7),
      indicatorColor: colorScheme.primary,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: colorScheme.outlineVariant.withValues(alpha: 0.5),
    ),

    // Snackbar más elegante
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: tt.bodyMedium!.copyWith(color: colorScheme.onInverseSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

ThemeData lightTheme(ColorScheme? dynamicColorScheme) {
  // Si hay un esquema de colores dinámico, lo usamos
  final ColorScheme colorScheme = dynamicColorScheme ??
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF0074E0), // Azul más refinado para tema claro
        brightness: Brightness.light,
      ).copyWith(
        secondary: const Color(0xFF4BAEF8),
        tertiary: const Color(0xFF14B8A6), // Teal para acentos
        error: const Color(0xFFE53935), // Rojo más refinado
      );

  return _customize(ThemeData.light(useMaterial3: useMaterial3)).copyWith(
    colorScheme: colorScheme,
    // Fondo más limpio con un sutil degradado
    scaffoldBackgroundColor: colorScheme.surface.withAlpha(250),
    // Sombras más sutiles
    shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
  );
}

ThemeData darkTheme(ColorScheme? dynamicColorScheme) {
  // Si hay un esquema de colores dinámico, lo usamos
  final ColorScheme colorScheme = dynamicColorScheme ??
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF4BAEF8), // Azul brillante para tema oscuro
        brightness: Brightness.dark,
      ).copyWith(
        secondary: const Color(0xFF5AB5F9),
        tertiary: const Color(0xFF18D0BB), // Teal más brillante
        error: const Color(0xFFEF5350), // Rojo más visible en oscuridad
        surface: const Color(0xFF121212), // Fondo más oscuro
      );

  return _customize(ThemeData.dark(useMaterial3: useMaterial3)).copyWith(
    colorScheme: colorScheme,
    // Fondo oscuro con sutil tono azulado
    scaffoldBackgroundColor: const Color(0xFF101318),
    // Sombras más intensas para mejor contraste
    shadowColor: Colors.black.withValues(alpha: 0.3),
  );
}
