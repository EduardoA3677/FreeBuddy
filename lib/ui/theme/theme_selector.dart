import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_settings.dart';
import 'dimensions.dart';

/// Selector de tema que permite cambiar entre claro, oscuro y sistema
class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  static const themeOptions = [
    _ThemeOption(themeMode: ThemeMode.light, label: 'Claro', icon: Icons.light_mode_rounded),
    _ThemeOption(themeMode: ThemeMode.dark, label: 'Oscuro', icon: Icons.dark_mode_rounded),
    _ThemeOption(themeMode: ThemeMode.system, label: 'Sistema', icon: Icons.settings_suggest_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ThemeMode>(
      stream: context.read<AppSettings>().themeMode,
      builder: _themeSelectorBuilder,
    );
  }

  Widget _themeSelectorBuilder(BuildContext context, AsyncSnapshot<ThemeMode> snapshot) {
    final currentTheme = snapshot.data ?? ThemeMode.system;
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: AppDimensions.spacing8),
            child: Text(
              'Tema',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.spacing8,
                horizontal: AppDimensions.spacing4,
              ),
              child: Column(
                children: themeOptions
                    .map(
                      (option) => _themeOptionTile(
                        context,
                        option: option,
                        selected: currentTheme == option.themeMode,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _themeOptionTile(BuildContext context, {required _ThemeOption option, required bool selected}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colorScheme.primaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: InkWell(
        onTap: () => _setThemeMode(context, option.themeMode),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing16,
            vertical: AppDimensions.spacing12,
          ),
          child: Row(
            children: [
              Icon(
                option.icon,
                color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                size: AppDimensions.iconMedium,
              ),
              const SizedBox(width: AppDimensions.spacing16),
              Text(
                option.label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: selected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
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

class _ThemeOption {
  final ThemeMode themeMode;
  final String label;
  final IconData icon;

  const _ThemeOption({required this.themeMode, required this.label, required this.icon});
}
