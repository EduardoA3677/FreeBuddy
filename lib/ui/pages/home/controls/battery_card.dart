import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../gen/freebuddy_icons.dart';
import '../../../../headphones/framework/lrc_battery.dart';
import '../../../../headphones/huawei/features/battery_feature.dart';

/// Tarjeta de batería con estilo moderno Material 3
///
/// Rediseñada con un enfoque más limpio y visual
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
          elevation: hasData ? 2 : 1,
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
                // Diseño moderno para el encabezado
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
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
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),

                // Indicadores de batería con diseño mejorado
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

  // Estado de carga cuando no hay datos disponibles
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
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
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

/// Indicador de batería con diseño visual mejorado
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

    // Colores modernos para los niveles de batería
    Color getBatteryColor() {
      if (level == null) return theme.colorScheme.surfaceContainerHighest;
      if (level! < 20) {
        return theme.colorScheme.error;
      } else if (level! < 40) {
        return theme.colorScheme.error.withValues(alpha: 0.7);
      } else if (level! < 70) {
        return theme.colorScheme.tertiary;
      } else {
        return theme.colorScheme.primary.withGreen((theme.colorScheme.primary.g + 30).toInt());
      }
    }

    // Determinar el ancho de la barra según nivel
    final barWidth = level != null ? (level! / 100) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Icono con fondo
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
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Información de porcentaje y carga
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          level != null ? '$level%' : '--',
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
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Symbols.bolt,
                                size: fontSize - 2,
                                color: Colors.green.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Charging',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.green.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ).animate().scale(
                              duration: 2.seconds,
                              curve: Curves.easeInOut,
                              begin: Offset(1.0, 1.0),
                              end: Offset(1.05, 1.05),
                              alignment: Alignment.center,
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Barra de progreso con estilo moderno
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          child: Row(
            children: [
              if (level != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  width: MediaQuery.of(context).size.width * 0.65 * barWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: getBatteryColor(),
                    boxShadow: [
                      BoxShadow(
                        color: getBatteryColor().withValues(alpha: 0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
