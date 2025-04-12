// ... importaciones
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../gen/freebuddy_icons.dart';
import '../../../../headphones/framework/lrc_battery.dart';
import '../../../../headphones/huawei/features/battery_feature.dart';

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
          elevation: hasData ? 4 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: theme.colorScheme.surface,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withAlpha(180),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Symbols.battery_horiz_075,
                        color: theme.colorScheme.primary,
                        size: isSmallDevice ? 20 : 24,
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack, delay: 100.ms),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Battery',
                            style: textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallDevice ? 18 : 20,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Levels and charging status',
                            style: textTheme.bodySmall?.copyWith(
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
                  color: theme.colorScheme.outlineVariant.withAlpha(128),
                ),
                if (!hasData)
                  _buildLoadingState(theme, isSmallDevice)
                else
                  Column(
                    children: [
                      BatteryIndicator(
                        icon: FreebuddyIcons.leftEarbud,
                        text: 'Left Earbud',
                        level: levels.levelLeft,
                        charging: levels.chargingLeft,
                        fontSize: isSmallDevice ? 14 : 16,
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 150.ms)
                          .slideX(begin: -0.1, end: 0),
                      SizedBox(height: isSmallDevice ? 14 : 18),
                      BatteryIndicator(
                        icon: FreebuddyIcons.rightEarbud,
                        text: 'Right Earbud',
                        level: levels.levelRight,
                        charging: levels.chargingRight,
                        fontSize: isSmallDevice ? 14 : 16,
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 250.ms)
                          .slideX(begin: -0.1, end: 0),
                      SizedBox(height: isSmallDevice ? 14 : 18),
                      BatteryIndicator(
                        icon: FreebuddyIcons.earbudsCase,
                        text: 'Case',
                        level: levels.levelCase,
                        charging: levels.chargingCase,
                        fontSize: isSmallDevice ? 14 : 16,
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 350.ms)
                          .slideX(begin: -0.1, end: 0),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

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
              color: theme.colorScheme.primary.withAlpha(180),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading battery information...',
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
      if (level! < 20) return theme.colorScheme.error.withAlpha(180);
      if (level! < 40) return theme.colorScheme.tertiary;
      if (level! < 70) return theme.colorScheme.primary.withAlpha(180);
      return theme.colorScheme.primary;
    }

    final barFill = level != null ? (level!.clamp(0, 100) / 100.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: fontSize + 2,
              ),
            ),
            const SizedBox(width: 12),
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
                  const SizedBox(height: 4),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(40),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Symbols.bolt,
                                size: fontSize - 2,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
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
        const SizedBox(height: 8),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                width: MediaQuery.of(context).size.width * 0.6 * barFill,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
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
