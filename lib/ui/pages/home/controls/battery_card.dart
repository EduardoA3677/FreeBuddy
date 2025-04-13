// ... importaciones
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../gen/freebuddy_icons.dart';
import '../../../../headphones/framework/lrc_battery.dart';
import '../../../../headphones/huawei/features/battery_feature.dart';
import '../../../theme/dimensions.dart';

class BatteryCard extends StatelessWidget {
  final LRCBattery lrcBattery;

  const BatteryCard(this.lrcBattery, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallDevice = screenWidth < 360;

    return StreamBuilder<LRCBatteryLevels>(
      stream: lrcBattery is BatteryFeature
          ? (lrcBattery as BatteryFeature).batteryLevels
          : lrcBattery.lrcBattery,
      builder: (context, snapshot) {
        final levels = snapshot.data;
        final hasData = levels != null;

        return Card(
          elevation: hasData ? AppDimensions.elevationMedium : AppDimensions.elevationSmall,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          ),
          color: theme.colorScheme.surfaceContainerHigh, // Color más oscuro para mejor contraste
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
            padding:
                EdgeInsets.all(isSmallDevice ? AppDimensions.spacing12 : AppDimensions.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppDimensions.spacing8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      ),
                      child: Icon(
                        Symbols.battery_horiz_075,
                        color: theme.colorScheme.primary,
                        size: isSmallDevice ? AppDimensions.iconSmall : AppDimensions.iconMedium,
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack, delay: 100.ms),
                    SizedBox(width: AppDimensions.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Battery',
                            style: textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallDevice
                                  ? AppDimensions.textMedium
                                  : AppDimensions.textLarge - 2,
                            ),
                          ),
                          SizedBox(height: AppDimensions.spacing2),
                          Text(
                            'Levels and charging status',
                            style: textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: isSmallDevice
                                  ? AppDimensions.textXSmall
                                  : AppDimensions.textSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: AppDimensions.spacing24,
                  indent: AppDimensions.spacing8,
                  endIndent: AppDimensions.spacing8,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                if (!hasData)
                  _buildLoadingState(theme, isSmallDevice)
                else
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calcula si hay suficiente espacio para diseño horizontal o vertical
                        final hasEnoughHeight = constraints.maxHeight > 200;

                        if (hasEnoughHeight) {
                          // Diseño vertical tradicional para espacios altos
                          return Column(
                            children: [
                              Expanded(
                                child: BatteryIndicator(
                                  icon: FreebuddyIcons.leftEarbud,
                                  text: 'Left Earbud',
                                  level: levels.levelLeft,
                                  charging: levels.chargingLeft,
                                  fontSize: isSmallDevice
                                      ? AppDimensions.textSmall + 2
                                      : AppDimensions.textMedium,
                                )
                                    .animate()
                                    .fadeIn(duration: 400.ms, delay: 150.ms)
                                    .slideX(begin: -0.1, end: 0),
                              ),
                              Expanded(
                                child: BatteryIndicator(
                                  icon: FreebuddyIcons.rightEarbud,
                                  text: 'Right Earbud',
                                  level: levels.levelRight,
                                  charging: levels.chargingRight,
                                  fontSize: isSmallDevice
                                      ? AppDimensions.textSmall + 2
                                      : AppDimensions.textMedium,
                                )
                                    .animate()
                                    .fadeIn(duration: 400.ms, delay: 250.ms)
                                    .slideX(begin: -0.1, end: 0),
                              ),
                              Expanded(
                                child: BatteryIndicator(
                                  icon: FreebuddyIcons.earbudsCase,
                                  text: 'Case',
                                  level: levels.levelCase,
                                  charging: levels.chargingCase,
                                  fontSize: isSmallDevice
                                      ? AppDimensions.textSmall + 2
                                      : AppDimensions.textMedium,
                                )
                                    .animate()
                                    .fadeIn(duration: 400.ms, delay: 350.ms)
                                    .slideX(begin: -0.1, end: 0),
                              ),
                            ],
                          );
                        } else {
                          // Diseño compacto para espacios reducidos
                          return Column(
                            children: [
                              _buildCompactBatteryRow(
                                context,
                                levels,
                                isSmallDevice,
                                theme,
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactBatteryRow(
    BuildContext context,
    LRCBatteryLevels levels,
    bool isSmallDevice,
    ThemeData theme,
  ) {
    // No necesitamos screenWidth aquí
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildCompactBatteryIndicator(
              icon: FreebuddyIcons.leftEarbud,
              label: 'Left',
              level: levels.levelLeft,
              charging: levels.chargingLeft,
              theme: theme,
              delay: 150,
            ),
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildCompactBatteryIndicator(
              icon: FreebuddyIcons.rightEarbud,
              label: 'Right',
              level: levels.levelRight,
              charging: levels.chargingRight,
              theme: theme,
              delay: 250,
            ),
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildCompactBatteryIndicator(
              icon: FreebuddyIcons.earbudsCase,
              label: 'Case',
              level: levels.levelCase,
              charging: levels.chargingCase,
              theme: theme,
              delay: 350,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactBatteryIndicator({
    required IconData icon,
    required String label,
    required int? level,
    required bool charging,
    required ThemeData theme,
    required int delay,
  }) {
    Color getBatteryColor() {
      if (level == null || level == 0) return theme.colorScheme.error;
      if (level < 20) return theme.colorScheme.error.withValues(alpha: 0.85);
      if (level < 40) return theme.colorScheme.tertiary;
      if (level < 70) return theme.colorScheme.primary.withValues(alpha: 0.85);
      return theme.colorScheme.primary;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: getBatteryColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              level != null ? '$level%' : '--%',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: getBatteryColor(),
              ),
            ),
          ),
          if (charging)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Symbols.bolt,
                    size: 12,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'Charging',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ).animate().fadeIn(duration: 400.ms, delay: delay.ms),
    );
  }
}

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
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: AppDimensions.spacing16),
        Text(
          'Loading battery information...',
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

class BatteryIndicator extends StatelessWidget {
  final IconData icon;
  final String text;
  final int? level;
  final bool charging;
  final double fontSize;

  const BatteryIndicator({
    required this.icon,
    required this.text,
    required this.level,
    required this.charging,
    this.fontSize = 16.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color getBatteryColor() {
      if (level == null || level == 0) return theme.colorScheme.error;
      if (level! < 20) return theme.colorScheme.error.withValues(alpha: 0.85);
      if (level! < 40) return theme.colorScheme.tertiary;
      if (level! < 70) return theme.colorScheme.primary.withValues(alpha: 0.85);
      return theme.colorScheme.primary;
    }

    final barFill = level != null ? (level!.clamp(0, 100) / 100.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppDimensions.spacing6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: fontSize + 2,
              ),
            ),
            SizedBox(width: AppDimensions.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacing4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          level != null ? '$level%' : '--%',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: fontSize - 1,
                            color: getBatteryColor(),
                          ),
                        ),
                      ),
                      if (charging)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacing8, vertical: AppDimensions.spacing3),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Symbols.bolt,
                                size: fontSize - 2,
                                color: theme.colorScheme.primary,
                              ),
                              SizedBox(width: AppDimensions.spacing4),
                              Text(
                                'Charging',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spacing8),
        Container(
          height: AppDimensions.spacing8,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                width: MediaQuery.of(context).size.width * 0.6 * barFill,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall),
                  color: getBatteryColor(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
