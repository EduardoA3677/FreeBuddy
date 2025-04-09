import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../headphones/framework/anc.dart';

/// Card with ANC (Active Noise Control) controls
class AncCard extends StatelessWidget {
  final Anc anc;

  const AncCard(this.anc, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Noise Control',
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
                    _buildAncButton(
                      context,
                      icon: Symbols.noise_control_on,
                      label: 'Noise Cancelling',
                      isSelected: mode == AncMode.noiseCancelling,
                      onPressed: () => anc.setAncMode(AncMode.noiseCancelling),
                    ),
                    _buildAncButton(
                      context,
                      icon: Symbols.noise_control_off,
                      label: 'Off',
                      isSelected: mode == AncMode.off,
                      onPressed: () => anc.setAncMode(AncMode.off),
                    ),
                    _buildAncButton(
                      context,
                      icon: Symbols.noise_aware,
                      label: 'Transparency',
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

  Widget _buildAncButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surfaceContainerHighest;
    final alpha = (0.3 * 255).round();

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isSelected ? theme.colorScheme.primaryContainer : surfaceColor.withAlpha(alpha),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 24,
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
