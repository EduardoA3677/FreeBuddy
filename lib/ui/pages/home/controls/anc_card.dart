import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../headphones/framework/anc.dart';

/// Card with modern ANC controls
class AncCard extends StatelessWidget {
  final Anc anc;

  const AncCard(this.anc, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallDevice = screenWidth < 360;

    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withAlpha(240),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modern header design
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Symbols.noise_aware,
                    color: theme.colorScheme.secondary,
                    size: isSmallDevice ? 20 : 24,
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack, delay: 100.ms),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.ancNoiseControl,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: isSmallDevice ? 18 : 20,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Adjust noise cancellation settings',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: isSmallDevice ? 12 : 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Divider(
              height: 32,
              indent: 8,
              endIndent: 8,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),

            StreamBuilder<AncMode>(
              stream: anc.ancMode,
              builder: (context, snapshot) {
                final mode = snapshot.data;
                final hasError = snapshot.hasError;
                final isLoading = !snapshot.hasData && !hasError;

                // Show loading state
                if (isLoading) {
                  return _buildLoadingState(theme, isSmallDevice);
                }

                // Show error state if there's an error
                if (hasError) {
                  return _buildErrorState(theme, l, context);
                }

                // Responsive layout based on screen width
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final useVerticalLayout = isSmallDevice || screenWidth < 400;

                    final ancButtons = [
                      AncModeOption(
                        icon: Symbols.noise_control_on,
                        label: l.ancNoiseCancel,
                        description: l.ancNoiseCancelDesc,
                        isSelected: mode == AncMode.noiseCancelling,
                        onPressed: () => anc.setAncMode(AncMode.noiseCancelling),
                      ),
                      AncModeOption(
                        icon: Symbols.noise_control_off,
                        label: l.ancOff,
                        description: l.ancOffDesc,
                        isSelected: mode == AncMode.off,
                        onPressed: () => anc.setAncMode(AncMode.off),
                      ),
                      AncModeOption(
                        icon: Symbols.hearing,
                        label: l.ancAwareness,
                        description: l.ancAwarenessDesc,
                        isSelected: mode == AncMode.transparency,
                        onPressed: () => anc.setAncMode(AncMode.transparency),
                      ),
                    ];

                    if (useVerticalLayout) {
                      return Column(
                        children: ancButtons
                            .asMap()
                            .entries
                            .map((entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: entry.value
                                        .animate()
                                        .fadeIn(
                                            duration: 400.ms, delay: 150.ms * entry.key.toDouble())
                                        .slideX(
                                            begin: 0.05,
                                            end: 0,
                                            duration: 400.ms,
                                            delay: 150.ms * entry.key.toDouble()),
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
                                            duration: 400.ms, delay: 150.ms * entry.key.toDouble())
                                        .slideY(
                                            begin: 0.05,
                                            end: 0,
                                            duration: 400.ms,
                                            delay: 150.ms * entry.key.toDouble()),
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

  // Loading state widget
  Widget _buildLoadingState(ThemeData theme, bool isSmall) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: isSmall ? 30 : 40,
            height: isSmall ? 30 : 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: theme.colorScheme.secondary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading noise control settings...',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: isSmall ? 13 : 14,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  // Error state widget
  Widget _buildErrorState(ThemeData theme, AppLocalizations l, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Symbols.error_outline,
            color: theme.colorScheme.error,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            l.ancControlError,
            style: TextStyle(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Symbols.refresh),
            onPressed: () => anc.setAncMode(AncMode.off),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
            ),
            label: Text(l.headphonesControlRetry),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).shake(delay: 200.ms);
  }
}

/// Widget for ANC mode options with modern visual styling
class AncModeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback? onPressed;

  const AncModeOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Colors for selected/unselected state with modern look
    final backgroundColor = isSelected
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest.withAlpha(180);

    final foregroundColor =
        isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface;

    // Elevation effect for selected item
    final elevation = isSelected ? 3.0 : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (elevation > 0)
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.15),
              blurRadius: elevation * 2,
              offset: Offset(0, elevation),
            ),
        ],
        border: Border.all(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: LayoutBuilder(builder: (context, constraints) {
              final isSmallWidth = constraints.maxWidth < 120;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated icon container
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.2)
                          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? theme.colorScheme.primary : foregroundColor,
                      size: 26,
                    ),
                  )
                      .animate(target: isSelected ? 1 : 0)
                      .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.1, 1.1)),

                  const SizedBox(height: 12),

                  // Label with adaptive size
                  Text(
                    label,
                    style: TextStyle(
                      color: foregroundColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: isSmallWidth ? 14 : 16,
                    ),
                  ),

                  // Description for clarity
                  if (!isSmallWidth) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ]
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
