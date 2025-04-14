import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_settings.dart';
import 'dimensions.dart';

/// Selector de tema que permite cambiar entre claro, oscuro y sistema
class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ThemeMode>(
      stream: context.read<AppSettings>().themeMode,
      builder: (context, snapshot) {
        final currentTheme = snapshot.data ?? ThemeMode.system;

        return Padding(
          padding: EdgeInsets.all(AppDimensions.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(left: AppDimensions.spacing8),
                child: Text(
                  'Tema',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              SizedBox(height: AppDimensions.spacing8),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: AppDimensions.spacing8,
                      horizontal: AppDimensions.spacing4),
                  child: Column(
                    children: [
                      _buildThemeOption(
                        context,
                        title: 'Claro',
                        icon: Icons.light_mode_rounded,
                        selected: currentTheme == ThemeMode.light,
                        onTap: () => _setThemeMode(context, ThemeMode.light),
                      ),
                      _buildThemeOption(
                        context,
                        title: 'Oscuro',
                        icon: Icons.dark_mode_rounded,
                        selected: currentTheme == ThemeMode.dark,
                        onTap: () => _setThemeMode(context, ThemeMode.dark),
                      ),
                      _buildThemeOption(
                        context,
                        title: 'Sistema',
                        icon: Icons.settings_suggest_rounded,
                        selected: currentTheme == ThemeMode.system,
                        onTap: () => _setThemeMode(context, ThemeMode.system),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: selected ? colorScheme.primaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing16,
              vertical: AppDimensions.spacing12),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: AppDimensions.iconMedium,
              ),
              SizedBox(width: AppDimensions.spacing16),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: selected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
              const Spacer(),
              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: colorScheme.primary,
                  size: AppDimensions.iconMedium,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _setThemeMode(BuildContext context, ThemeMode mode) {
    context.read<AppSettings>().setThemeMode(mode);
  }
}
