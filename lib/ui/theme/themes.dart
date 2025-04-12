import 'package:flutter/material.dart';

// Material 3 está habilitado por defecto en versiones recientes de Flutter
bool get useMaterial3 => true;

/// Personaliza ambos temas (claro y oscuro) con un estilo más moderno y elegante
ThemeData _customize(ThemeData theme) {
  final tt = theme.textTheme;
  final colorScheme = theme.colorScheme;

  return theme.copyWith(
    // Tarjetas con diseño moderno 2025 - bordes suaves, sombras elegantes y esquinas redondeadas
    cardTheme: CardTheme(
      elevation: 2.5,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
    ),

    // Botones principales con diseño moderno 2025 - bordes suaves y efecto de elevación
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        elevation: 2,
        shadowColor: colorScheme.primary.withValues(alpha: 0.4),
        textStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0.3,
        ),
      ).copyWith(
        overlayColor: WidgetStatePropertyAll(colorScheme.onPrimary.withValues(alpha: 0.15)),
        // Animación sutil al presionar - tendencia 2025
        animationDuration: const Duration(milliseconds: 250),
      ),
    ),

    // Botones secundarios con estilo moderno - efecto de cristal (glassmorphism) tendencia 2025
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 1.5,
        backgroundColor: colorScheme.surfaceContainerHigh.withValues(alpha: 0.85),
        foregroundColor: colorScheme.primary,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.25),
      ).copyWith(
        // Efectos modernos al interactuar - tendencia UI 2025
        overlayColor: WidgetStatePropertyAll(colorScheme.primary.withValues(alpha: 0.15)),
        animationDuration: const Duration(milliseconds: 200),
      ),
    ),

    // Botones terciarios con bordes modernos y efectos de hover - tendencia 2025
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: BorderSide(width: 1.5, color: colorScheme.primary.withAlpha(180)),
        foregroundColor: colorScheme.primary,
      ).copyWith(
        overlayColor: WidgetStatePropertyAll(colorScheme.primary.withValues(alpha: 0.08)),
        // Transición suave al pasar el cursor - tendencia 2025
        animationDuration: const Duration(milliseconds: 250),
      ),
    ),

    // Input decorations más modernas con efecto glassmorphism - tendencia 2025
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerLowest.withAlpha(230),
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
      // Añadido para 2025: sombras sutiles y efectos al enfocar
      isDense: false,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      floatingLabelStyle: TextStyle(
        color: colorScheme.primary,
        fontWeight: FontWeight.w500,
      ),
      prefixIconColor: colorScheme.primary.withAlpha(220),
      suffixIconColor: colorScheme.onSurfaceVariant,
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
        tertiary: const Color(0xFF2DD4C0), // Teal más vibrante para 2025
        error: const Color(0xFFE53935), // Rojo más refinado
        // Nuevos colores para 2025 - más vibrantes y modernos
        primaryContainer: const Color(0xFFDEF0FF),
        secondaryContainer: const Color(0xFFE4F4FF),
        tertiaryContainer: const Color(0xFFCCF7F0),
        surface: const Color(0xFFF8FAFD), // Superficies más claras y modernas
        surfaceContainerHighest: const Color(0xFFF0F3F9),
      );

  return _customize(ThemeData.light(useMaterial3: useMaterial3)).copyWith(
    colorScheme: colorScheme,
    // Fondo más limpio con un sutil degradado
    scaffoldBackgroundColor: colorScheme.surface.withAlpha(250),
    // Sombras más sutiles pero visualmente atractivas
    shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
    // Mejor visualización de tarjetas 2025
    cardTheme: CardTheme(
      elevation: 2,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
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
        tertiary: const Color(0xFF20E8D0), // Teal más brillante y moderno para 2025
        error: const Color(0xFFFF5C5C), // Rojo más visible y vibrante en oscuridad
        surface: const Color(0xFF151920), // Fondo más oscuro con tono azul moderno
        // Nuevos colores para tema oscuro 2025
        primaryContainer: const Color(0xFF0D2B4E),
        secondaryContainer: const Color(0xFF0E304A),
        tertiaryContainer: const Color(0xFF0F3632),
        surfaceContainerHighest: const Color(0xFF1E232D),
        onSurface: const Color(0xFFE1E5F2),
        onPrimary: const Color(0xFFE8F4FF),
      );

  return _customize(ThemeData.dark(useMaterial3: useMaterial3)).copyWith(
    colorScheme: colorScheme,
    // Fondo oscuro con sutil tono azulado - tendencia en 2025
    scaffoldBackgroundColor: const Color(0xFF0A0E17),
    // Sombras más intensas para mejor contraste
    shadowColor: Colors.black.withValues(alpha: 0.4),
    // Mejor visualización de tarjetas para 2025
    cardTheme: CardTheme(
      elevation: 3,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
  );
}
