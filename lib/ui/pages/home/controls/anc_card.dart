import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../headphones/framework/anc.dart';
import '../../../theme/dimensions.dart';

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
      elevation: AppDimensions.elevationSmall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      // Color más oscuro para mejor contraste
      color: theme.colorScheme.surfaceContainerHigh,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surfaceContainerHigh,
              theme.colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
        padding: EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modern header design
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppDimensions.spacing8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: Icon(
                    Symbols.noise_aware,
                    color: theme.colorScheme.secondary,
                    size:
                        isSmallDevice ? AppDimensions.iconSmall + 6 : AppDimensions.iconMedium + 4,
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack, delay: 100.ms),
                SizedBox(width: AppDimensions.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.ancNoiseControl,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize:
                              isSmallDevice ? AppDimensions.textMedium : AppDimensions.textLarge,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spacing2),
                      Text(
                        'Adjust noise cancellation settings',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize:
                              isSmallDevice ? AppDimensions.textXSmall : AppDimensions.textSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Divider(
              height: AppDimensions.spacing32,
              indent: AppDimensions.spacing8,
              endIndent: AppDimensions.spacing8,
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

                    // Crear los botones de ANC con tamaños iguales
                    final ancButtons = [
                      SizedBox(
                        width: double.infinity,
                        child: AncModeOption(
                          icon: Symbols.noise_control_on,
                          label: l.ancNoiseCancel,
                          description: l.ancNoiseCancelDesc,
                          isSelected: mode == AncMode.noiseCancelling,
                          onPressed: () => anc.setAncMode(AncMode.noiseCancelling),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: AncModeOption(
                          icon: Symbols.noise_control_off,
                          label: l.ancOff,
                          description: l.ancOffDesc,
                          isSelected: mode == AncMode.off,
                          onPressed: () => anc.setAncMode(AncMode.off),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: AncModeOption(
                          icon: Symbols.hearing,
                          label: l.ancAwareness,
                          description: l.ancAwarenessDesc,
                          isSelected: mode == AncMode.transparency,
                          onPressed: () => anc.setAncMode(AncMode.transparency),
                        ),
                      ),
                    ];

                    if (useVerticalLayout) {
                      return Column(
                        children: ancButtons
                            .asMap()
                            .entries
                            .map((entry) => Padding(
                                  padding: EdgeInsets.only(
                                    bottom: entry.key < 2 ? 12.0 : 0.0,
                                  ),
                                  child: entry.value
                                      .animate()
                                      .fadeIn(
                                          duration: 400.ms, delay: 150.ms * entry.key.toDouble())
                                      .slideX(
                                          begin: 0.05,
                                          end: 0,
                                          duration: 400.ms,
                                          delay: 150.ms * entry.key.toDouble()),
                                ))
                            .toList(),
                      );
                    } else {
                      return Row(
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
            width: isSmall ? AppDimensions.spacing30 : AppDimensions.spacing40,
            height: isSmall ? AppDimensions.spacing30 : AppDimensions.spacing40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: theme.colorScheme.secondary.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: AppDimensions.spacing16),
          Text(
            'Loading noise control settings...',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: isSmall ? AppDimensions.textSmall : AppDimensions.textMedium - 2,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  // Error state widget
  Widget _buildErrorState(ThemeData theme, AppLocalizations l, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Column(
        children: [
          Icon(
            Symbols.error_outline,
            color: theme.colorScheme.error,
            size: AppDimensions.iconLarge,
          ),
          SizedBox(height: AppDimensions.spacing12),
          Text(
            l.ancControlError,
            style: TextStyle(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimensions.spacing16),
          OutlinedButton.icon(
            icon: const Icon(Symbols.refresh),
            onPressed: () => anc.setAncMode(AncMode.off),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
              padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing16, vertical: AppDimensions.spacing8),
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
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8);

    final foregroundColor =
        isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface;

    // Elevation effect for selected item
    final elevation = isSelected ? AppDimensions.elevationSmall : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
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
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing16, vertical: AppDimensions.spacing16),
            child: LayoutBuilder(builder: (context, constraints) {
              final isSmallWidth = constraints.maxWidth < 120;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated icon container
                  Container(
                    padding: EdgeInsets.all(AppDimensions.spacing8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.2)
                          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? theme.colorScheme.primary : foregroundColor,
                      size: AppDimensions.iconMedium + 2,
                    ),
                  )
                      .animate(target: isSelected ? 1 : 0)
                      .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.1, 1.1)),

                  SizedBox(height: AppDimensions.spacing12),

                  // Label with adaptive size
                  Text(
                    label,
                    style: TextStyle(
                      color: foregroundColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize:
                          isSmallWidth ? AppDimensions.textSmall + 2 : AppDimensions.textMedium,
                    ),
                  ),

                  // Description for clarity
                  if (!isSmallWidth) ...[
                    SizedBox(height: AppDimensions.spacing4),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: AppDimensions.textXSmall,
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
