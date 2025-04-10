import 'package:flutter/material.dart';

// Material 3 está habilitado por defecto en versiones recientes de Flutter
bool get useMaterial3 => true;

/// Personaliza ambos temas (claro y oscuro)
ThemeData _customize(ThemeData theme) {
  final tt = theme.textTheme;
  return theme.copyWith(
    // Aplicamos elevaciones y sombras suaves pero visibles para mejor jerarquía visual
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    // Personalizamos los botones para tener bordes más redondeados
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    // Personalización de texto más moderna
    textTheme: tt.copyWith(
      // Display
      displaySmall: tt.displaySmall!.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
      displayMedium: tt.displayMedium!.copyWith(
        color: tt.bodyMedium!.color,
        fontWeight: FontWeight.w500,
      ),
      // Body
      bodyMedium: tt.bodyMedium!.copyWith(
        fontSize: 15.0,
      ),
      bodyLarge: tt.bodyLarge!.copyWith(
        fontSize: 17.0,
      ),
      // Headlines
      headlineSmall: tt.headlineSmall!.copyWith(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: tt.headlineMedium!.copyWith(
        color: tt.bodyMedium!.color,
        fontSize: 28.0,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: tt.headlineLarge!.copyWith(
        color: tt.bodyMedium!.color,
        fontSize: 32.0,
        fontWeight: FontWeight.w700,
      ),
    ),
    // Personalización de los appbar
    appBarTheme: theme.appBarTheme.copyWith(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 2,
    ),
  );
}

ThemeData lightTheme(ColorScheme? dynamicColorScheme) {
  // Si hay un esquema de colores dinámico, lo usamos
  final ColorScheme colorScheme = dynamicColorScheme ??
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF0A84FF), // Color azul vibrante para tema claro
        brightness: Brightness.light,
      );
  return _customize(ThemeData.light(useMaterial3: useMaterial3)).copyWith(
    colorScheme: colorScheme,
    // Añadimos un fondo sutilmente coloreado para más personalidad
    scaffoldBackgroundColor: colorScheme.surface.withAlpha(242),
  );
}

ThemeData darkTheme(ColorScheme? dynamicColorScheme) {
  // Si hay un esquema de colores dinámico, lo usamos
  final ColorScheme colorScheme = dynamicColorScheme ??
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF38B0FF), // Color azul más brillante para tema oscuro
        brightness: Brightness.dark,
      );
  return _customize(ThemeData.dark(useMaterial3: useMaterial3)).copyWith(
    colorScheme: colorScheme,
    // Fondo ligeramente más oscuro que el estándar para mejor contraste
    scaffoldBackgroundColor: colorScheme.surface.withAlpha(250),
  );
}
