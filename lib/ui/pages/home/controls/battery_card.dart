import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../gen/freebuddy_icons.dart';
import '../../../../headphones/framework/lrc_battery.dart';
import '../../../../headphones/huawei/features/battery_feature.dart';

/// Tarjeta de batería con estilo moderno Material 3
///
/// Inspirada en el widget de batería de Google Pixel para Android 12+
class BatteryCard extends StatelessWidget {
  final LRCBattery lrcBattery;

  const BatteryCard(this.lrcBattery, {super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // Tamaños de fuente responsivos
    final titleSize = screenWidth < 360 ? 18.0 : 20.0;
    final fontSize = screenWidth < 360 ? 14.0 : 16.0;

    return StreamBuilder<LRCBatteryLevels>(
      stream: lrcBattery is BatteryFeature
          ? (lrcBattery as BatteryFeature).batteryLevels
          : lrcBattery.lrcBattery,
      builder: (context, snapshot) {
        final levels = snapshot.data;

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
                      Symbols.battery_horiz_075,
                      color: theme.colorScheme.primary,
                      size: titleSize + 4,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Battery',
                      style: textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: titleSize,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Subtítulo
                Text(
                  'Levels and charging status',
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Divider(height: 24),
                // Indicadores de batería con barras de progreso
                BatteryIndicator(
                  icon: FreebuddyIcons.leftEarbud,
                  text: 'Left Earbud',
                  level: levels?.levelLeft,
                  charging: levels?.chargingLeft ?? false,
                  fontSize: fontSize,
                ),
                const SizedBox(height: 16),
                BatteryIndicator(
                  icon: FreebuddyIcons.rightEarbud,
                  text: 'Right Earbud',
                  level: levels?.levelRight,
                  charging: levels?.chargingRight ?? false,
                  fontSize: fontSize,
                ),
                const SizedBox(height: 16),
                BatteryIndicator(
                  icon: FreebuddyIcons.earbudsCase,
                  text: 'Case',
                  level: levels?.levelCase,
                  charging: levels?.chargingCase ?? false,
                  fontSize: fontSize,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Indicador de batería mejorado con barra de progreso
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
    final theme = Theme.of(context); // Determinar color de batería según nivel
    Color getBatteryColor() {
      if (level == null) return theme.colorScheme.surfaceContainerHighest;
      if (level! < 20) return Colors.red;
      if (level! < 50) return Colors.orange;
      return Colors.green.shade600;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: fontSize + 4),
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
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize - 2,
                            color: getBatteryColor(),
                          ),
                        ),
                      ),
                      if (charging)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Symbols.bolt,
                              size: fontSize - 2,
                              color: Colors.green,
                            ),
                            Text(
                              'Charging',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Barra de progreso para nivel de batería
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: level != null ? level! / 100 : 0,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: getBatteryColor(),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
