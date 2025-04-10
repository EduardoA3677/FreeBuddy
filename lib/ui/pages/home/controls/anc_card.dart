import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../headphones/framework/anc.dart';

/// Tarjeta de control de cancelación de ruido (ANC)
///
/// Muestra las opciones disponibles para los modos de ANC con una visualización mejorada
class AncCard extends StatelessWidget {
  final Anc anc;

  const AncCard(this.anc, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera de la tarjeta con icono
            Row(
              children: [
                Icon(
                  Symbols.noise_aware,
                  color: theme.colorScheme.primary,
                  size: 26,
                ),
                const SizedBox(width: 8),
                Text(
                  l.ancNoiseControl,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Subtítulo
            Text(
              'Adjust noise cancellation settings',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Divider(height: 24),
            StreamBuilder<AncMode>(
              stream: anc.ancMode,
              builder: (context, snapshot) {
                final mode = snapshot.data;
                final hasError = snapshot.hasError;

                // Show error state if there's an error
                if (hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Symbols.error_outline, color: theme.colorScheme.error),
                        const SizedBox(height: 8),
                        Text(
                          l.ancControlError,
                          style: TextStyle(color: theme.colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () => anc.setAncMode(AncMode.off),
                          child: Text(l.headphonesControlRetry),
                        ),
                      ],
                    ),
                  );
                }

                // Diseño adaptable según el ancho de pantalla
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmallScreen = constraints.maxWidth < 360;
                    final useVerticalLayout = isSmallScreen || screenWidth < 400;

                    final ancButtons = [
                      AncModeOption(
                        icon: Symbols.noise_control_on,
                        label: l.ancNoiseCancel,
                        description: l.ancNoiseCancelDesc,
                        isSelected: mode == AncMode.noiseCancelling,
                        onPressed: () {
                          // Capture the current context to avoid BuildContext across async gaps
                          final currentContext = context;
                          anc.setAncMode(AncMode.noiseCancelling).catchError((error) {
                            if (currentContext.mounted) {
                              ScaffoldMessenger.of(currentContext).showSnackBar(
                                SnackBar(content: Text(l.ancControlError)),
                              );
                            }
                          });
                        },
                      ),
                      AncModeOption(
                        icon: Symbols.noise_control_off,
                        label: l.ancOff,
                        description: l.ancOffDesc,
                        isSelected: mode == AncMode.off,
                        onPressed: () {
                          // Capture the current context to avoid BuildContext across async gaps
                          final currentContext = context;
                          anc.setAncMode(AncMode.off).catchError((error) {
                            if (currentContext.mounted) {
                              ScaffoldMessenger.of(currentContext).showSnackBar(
                                SnackBar(content: Text(l.ancControlError)),
                              );
                            }
                          });
                        },
                      ),
                      AncModeOption(
                        icon: Symbols.hearing,
                        label: l.ancAwareness,
                        description: l.ancAwarenessDesc,
                        isSelected: mode == AncMode.transparency,
                        onPressed: () {
                          // Capture the current context to avoid BuildContext across async gaps
                          final currentContext = context;
                          anc.setAncMode(AncMode.transparency).catchError((error) {
                            if (currentContext.mounted) {
                              ScaffoldMessenger.of(currentContext).showSnackBar(
                                SnackBar(content: Text(l.ancControlError)),
                              );
                            }
                          });
                        },
                      ),
                    ];

                    if (useVerticalLayout) {
                      return Column(
                        children: ancButtons
                            .asMap()
                            .entries
                            .map((entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: entry.value
                                        .animate()
                                        .fadeIn(
                                            duration: 300.ms, delay: 100.ms * entry.key.toDouble())
                                        .slideX(
                                            begin: 0.05,
                                            end: 0,
                                            duration: 300.ms,
                                            delay: 100.ms * entry.key.toDouble()),
                                  ),
                                ))
                            .toList(),
                      );
                    } else {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: ancButtons
                            .asMap()
                            .entries
                            .map((entry) => Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: entry.key == 1 ? 8.0 : 0,
                                    ),
                                    child: entry.value
                                        .animate()
                                        .fadeIn(
                                            duration: 300.ms, delay: 100.ms * entry.key.toDouble())
                                        .slideY(
                                            begin: 0.05,
                                            end: 0,
                                            duration: 300.ms,
                                            delay: 100.ms * entry.key.toDouble()),
                                  ),
                                ))
                            .toList(),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget de opción de modo ANC
class AncModeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onPressed;

  const AncModeOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onPressed,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Colores para el estado seleccionado/no seleccionado
    final backgroundColor = isSelected
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest.withAlpha(128);
    final foregroundColor =
        isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface;
    final borderColor = isSelected ? theme.colorScheme.primary : Colors.transparent;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: LayoutBuilder(builder: (context, constraints) {
            final isSmallWidth = constraints.maxWidth < 120;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: foregroundColor,
                  size: 28,
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: foregroundColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: isSmallWidth ? 12 : 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: foregroundColor.withAlpha(204),
                    fontSize: isSmallWidth ? 10 : 12,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                // Indicador visual cuando está seleccionado
                if (isSelected) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ],
            );
          }),
        ),
      ),
    );
  }
}
