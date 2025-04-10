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
                    AncButton(
                      icon: Symbols.noise_control_on,
                      label: 'Noise Cancelling',
                      isSelected: mode == AncMode.noiseCancelling,
                      onPressed: () => anc.setAncMode(AncMode.noiseCancelling),
                    ),
                    AncButton(
                      icon: Symbols.noise_control_off,
                      label: 'Off',
                      isSelected: mode == AncMode.off,
                      onPressed: () => anc.setAncMode(AncMode.off),
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
  final bool isSelected;
  final VoidCallback onPressed;

  const AncButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
