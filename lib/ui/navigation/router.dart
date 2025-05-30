import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/about/about_page.dart';
import '../pages/headphones_settings/headphones_settings_page.dart';
import '../pages/home/home_page.dart';
import '../pages/introduction/introduction.dart';
import '../pages/settings/settings_page.dart';

// Configuración centralizada de rutas usando GoRouter
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'headphones_settings',
          name: 'headphones_settings',
          builder: (context, state) => const HeadphonesSettingsPage(),
        ),
        GoRoute(
          path: 'introduction',
          name: 'introduction',
          builder: (context, state) => const FreebuddyIntroduction(),
        ),
        GoRoute(
          path: 'settings',
          name: 'settings',
          builder: (context, state) => const SettingsPage(),
          routes: [
            GoRoute(
              path: 'about',
              name: 'about',
              builder: (context, state) => const AboutPage(),
              routes: [
                GoRoute(
                  path: 'licenses',
                  name: 'licenses',
                  builder: (context, state) => const LicensePage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
  // Configuración de transiciones personalizadas
  observers: [NavigatorObserver()],
  // Maneja errores de navegación con soporte para Material 3
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(
      title: const Text('Error de navegación'),
      elevation: 0,
      scrolledUnderElevation: 2,
    ),
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: Ruta ${state.uri.path} no encontrada',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home),
                label: const Text('Ir al inicio'),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);

// Extensiones de navegación para hacer más sencillo navegar
extension NavigationExtensions on BuildContext {
  void navigateToHome() => GoRouter.of(this).go('/');

  void navigateToHeadphonesSettings() => GoRouter.of(this).go('/headphones_settings');

  void navigateToIntroduction() => GoRouter.of(this).go('/introduction');

  void navigateToSettings() => GoRouter.of(this).go('/settings');

  void navigateToAbout() => GoRouter.of(this).go('/settings/about');

  void navigateToLicenses() => GoRouter.of(this).go('/settings/about/licenses');
}
