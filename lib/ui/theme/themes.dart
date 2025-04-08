import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Maybe make a check for platform version, but honestly this is nice
bool get useMaterial3 => true;

/// This allows us to override both themes
ThemeData _customize(ThemeData theme) {
  final tt = theme.textTheme;
  return theme.copyWith(
    // Mejora de apariencia visual para soporte edge-to-edge
    appBarTheme: theme.appBarTheme.copyWith(
      elevation: 0,
      scrolledUnderElevation: 2.0,
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
    ),
    // Mejoras en elevaciones y sombras para una apariencia más moderna
    cardTheme: theme.cardTheme.copyWith(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    // Bordes redondeados para los botones
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textTheme: tt.copyWith(
      // Display
      displaySmall: tt.displaySmall!.copyWith(
        fontSize: 24,
      ),
      displayMedium: tt.displayMedium!.copyWith(
        color: tt.bodyMedium!.color,
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
      ),
      headlineMedium: tt.headlineMedium!.copyWith(
        color: tt.bodyMedium!.color,
        fontSize: 28.0,
      ),
      headlineLarge: tt.headlineLarge!.copyWith(
        color: tt.bodyMedium!.color,
        fontSize: 32.0,
      ),
    ),
  );
}

ThemeData lightTheme(ColorScheme? dynamicColorScheme) {
  return _customize(ThemeData.light(useMaterial3: useMaterial3)).copyWith(
    colorScheme: dynamicColorScheme,
    // colorScheme: _light.colorScheme.copyWith(
    // Leaving this so you see how you can customize colors individually
    //   shadow: const Color(0x80808080),
    // ),
  );
}

ThemeData darkTheme(ColorScheme? dynamicColorScheme) {
  return _customize(ThemeData.dark(useMaterial3: useMaterial3)).copyWith(
    colorScheme: dynamicColorScheme,
    // colorScheme: _dark.colorScheme.copyWith(
    //     // Leaving this so you see how you can customize colors individually
    //     ),
  );
}
