// filepath: /home/eduardo/FreeBuddy/lib/ui/pages/home/controls/battery_card.dart
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
            padding: EdgeInsets.all(AppDimensions.spacing12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado más compacto
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Symbols.battery_horiz_075,
                        color: theme.colorScheme.primary,
                        size: 22,
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
                ),

                Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),

                const SizedBox(height: 8),
                if (!hasData)
                  _buildLoadingState(theme, isSmallDevice)
                else
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Usar el diseño compacto para espacios pequeños
                        final isCompactHeight = constraints.maxHeight < 180;

                        if (isCompactHeight) {
                          return _buildCompactBatteryRow(context, levels, isSmallDevice, theme);
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: _buildSimpleBatteryRow(context, levels, theme),
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

  Widget _buildSimpleBatteryRow(
    BuildContext context,
    LRCBatteryLevels levels,
    ThemeData theme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBatteryItem(
          theme: theme,
          icon: FreebuddyIcons.leftEarbud,
          title: 'Izquierdo',
          level: levels.levelLeft,
          isCharging: levels.chargingLeft,
          animate: true,
          delay: 100,
        ),
        _buildBatteryItem(
          theme: theme,
          icon: FreebuddyIcons.rightEarbud,
          title: 'Derecho',
          level: levels.levelRight,
          isCharging: levels.chargingRight,
          animate: true,
          delay: 200,
        ),
        _buildBatteryItem(
          theme: theme,
          icon: FreebuddyIcons.earbudsCase,
          title: 'Estuche',
          level: levels.levelCase,
          isCharging: levels.chargingCase,
          animate: true,
          delay: 300,
        ),
      ],
    );
  }

  Widget _buildBatteryItem({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required int? level,
    required bool isCharging,
    bool animate = false,
    int delay = 0,
  }) {
    // Determina el color basado en el nivel de batería
    Color getBatteryColor() {
      if (level == null || level == 0) return theme.colorScheme.error;
      if (level < 20) return theme.colorScheme.error.withValues(alpha: 0.9);
      if (level < 40) return theme.colorScheme.tertiary;
      return theme.colorScheme.primary;
    }

    // Construye el indicador
    Widget batteryItem = Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono del auricular/estuche
            Icon(
              icon,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),

            // Título
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),

            // Nivel de batería con indicador visual
            Stack(
              alignment: Alignment.center,
              children: [
                // Contenedor de fondo
                Container(
                  width: double.infinity,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),

                // Barra de nivel de batería
                if (level != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      width: ((level.clamp(0, 100) / 100) * 100) * 0.8,
                      height: 8,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: getBatteryColor(),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                // Texto de porcentaje
                Text(
                  level != null ? '$level%' : '--',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Indicador de carga
            if (isCharging)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Symbols.bolt,
                      size: 10,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Cargando',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );

    // Aplicar animación si es necesario
    if (animate) {
      return batteryItem
          .animate()
          .fadeIn(duration: 300.ms, delay: delay.ms)
          .slideY(begin: 0.1, end: 0, delay: delay.ms);
    }

    return batteryItem;
  }

  // Método para mostrar la vista compacta horizontal de los tres indicadores
  Widget _buildCompactBatteryRow(
    BuildContext context,
    LRCBatteryLevels levels,
    bool isSmallDevice,
    ThemeData theme,
  ) {
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
                    'Cargando',
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

  // Método para mostrar el estado de carga
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
            'Cargando información de batería...',
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
}

// Componente para mostrar un indicador de batería individual (usado en diseño vertical)
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
                                'Cargando',
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
