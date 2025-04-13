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
          margin: EdgeInsets.zero,
          elevation: hasData ? AppDimensions.elevationSmall + 1 : AppDimensions.elevationSmall,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          ),
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
                stops: const [0.3, 1.0],
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado más compacto
                Row(
                  children: [
                    Icon(
                      Symbols.battery_horiz_075,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Battery',
                      style: textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                Divider(
                  height: 12,
                  thickness: 1,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),

                if (!hasData)
                  _buildLoadingState(theme, isSmallDevice)
                else
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompactHeight = constraints.maxHeight < 180;
                        // Usar el diseño compacto basado en la altura disponible
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          // Seleccionamos el diseño según el espacio disponible
                          child: isCompactHeight
                              ? _buildCompactBatteryRow(context, levels, isSmallDevice, theme)
                              : _buildSimpleBatteryRow(context, levels, theme),
                        );
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

  // Método para mostrar la vista compacta horizontal de los tres indicadores
  Widget _buildCompactBatteryRow(
    BuildContext context,
    LRCBatteryLevels levels,
    bool isSmallDevice,
    ThemeData theme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildCompactBatteryIndicator(
            icon: FreebuddyIcons.leftEarbud,
            label: 'Izq',
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
            label: 'Der',
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
            label: 'Estuche',
            level: levels.levelCase,
            charging: levels.chargingCase,
            theme: theme,
            delay: 350,
          ),
        ),
      ],
    );
  }

  // Método para mostrar la vista simple de los tres indicadores de batería
  Widget _buildSimpleBatteryRow(
    BuildContext context,
    LRCBatteryLevels levels,
    ThemeData theme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildCompactBatteryIndicator(
            icon: FreebuddyIcons.leftEarbud,
            label: 'Izq',
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
            label: 'Der',
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
            label: 'Estuche',
            level: levels.levelCase,
            charging: levels.chargingCase,
            theme: theme,
            delay: 350,
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20, // Reducido
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 2), // Reducido
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10, // Reducido
            ),
          ),
          const SizedBox(height: 2), // Reducido
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Reducido
            decoration: BoxDecoration(
              color: getBatteryColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8), // Reducido
            ),
            child: Text(
              level != null ? '$level%' : '--%',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: getBatteryColor(),
                fontSize: 12, // Reducido
              ),
            ),
          ),
          if (charging)
            Padding(
              padding: const EdgeInsets.only(top: 2.0), // Reducido
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Symbols.bolt,
                    size: 10, // Reducido
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'Cargando',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 8, // Reducido
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ).animate().fadeIn(duration: 250.ms, delay: delay.ms), // Animación más rápida
    );
  }

  // Método para mostrar el estado de carga
  Widget _buildLoadingState(ThemeData theme, bool isSmall) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: isSmall ? AppDimensions.spacing24 : AppDimensions.spacing30, // Reducido
            height: isSmall ? AppDimensions.spacing24 : AppDimensions.spacing30, // Reducido
            child: CircularProgressIndicator(
              strokeWidth: 2, // Reducido
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: AppDimensions.spacing8),
          Text(
            'Cargando información...',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: isSmall ? 10 : 12, // Reducido
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms); // Más rápido
  }
}
