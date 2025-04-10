import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../headphones/framework/anc.dart';

/// Card with ANC (Active Noise Control) controls
class AncCard extends StatelessWidget {
  final Anc anc;

  const AncCard(this.anc, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.ancNoiseControl,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<AncMode>(
              stream: anc.ancMode,
              builder: (context, snapshot) {
                final mode = snapshot.data;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AncButton(
                      icon: Symbols.noise_control_on,
                      label: l.ancNoiseCancel,
                      description: l.ancNoiseCancelDesc,
                      isSelected: mode == AncMode.noiseCancelling,
                      onPressed: () => anc.setAncMode(AncMode.noiseCancelling),
                    ),
                    AncButton(
                      icon: Symbols.noise_control_off,
                      label: l.ancOff,
                      description: l.ancOffDesc,
                      isSelected: mode == AncMode.off,
                      onPressed: () => anc.setAncMode(AncMode.off),
                    ),
                    AncButton(
                      icon: Symbols.hearing,
                      label: l.ancAwareness,
                      description: l.ancAwarenessDesc,
                      isSelected: mode == AncMode.transparency,
                      onPressed: () => anc.setAncMode(AncMode.transparency),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AncButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onPressed;

  const AncButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor =
        isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surface;
    final foregroundColor =
        isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: foregroundColor),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: foregroundColor.withAlpha(204),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
