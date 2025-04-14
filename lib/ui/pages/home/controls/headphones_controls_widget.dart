import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../headphones/framework/anc.dart';
import '../../../../headphones/framework/bluetooth_headphones.dart';
import '../../../../headphones/framework/headphones_info.dart';
import '../../../../headphones/framework/lrc_battery.dart';
import '../../../../headphones/huawei/huawei_headphones_base.dart';
import '../../../../headphones/huawei/huawei_headphones_impl.dart';
import '../../../../headphones/model_definition/huawei_models_definition.dart';
import '../../../../logger.dart';
import '../../../theme/layouts.dart';
import '../../../theme/dimensions.dart';
import 'anc_card.dart';
import 'battery_card.dart';
import 'headphones_image.dart';

class HeadphonesControlsWidget extends StatelessWidget {
  final BluetoothHeadphones headphones;
  final VoidCallback? onSettingsTap;

  const HeadphonesControlsWidget({
    super.key,
    required this.headphones,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final windowSize = WindowSizeClass.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final l = AppLocalizations.of(context)!;

    return Builder(
      builder: (context) {
        try {
          return _buildMainContent(context, windowSize, theme, l, screenWidth, screenHeight);
        } catch (e, stackTrace) {
          log(LogLevel.error, "Error rendering HeadphonesControlsWidget",
              error: e, stackTrace: stackTrace);
          return _buildErrorContent(
            l.headphonesControlError,
            l.headphonesControlErrorDesc,
            l,
            onRetry: () => (context as Element).markNeedsBuild(),
            theme: theme,
          );
        }
      },
    );
  }

  Widget _buildMainContent(BuildContext context, WindowSizeClass windowSize, ThemeData theme, AppLocalizations l,
      double screenWidth, double screenHeight) {
    log(LogLevel.debug, "Building main content for headphones: ${headphones.runtimeType}");

    HuaweiModelDefinition? modelDef;
    String deviceName = "";

    if (headphones is HuaweiHeadphonesBase) {
      if (headphones is HuaweiHeadphonesImpl) {
        modelDef = (headphones as HuaweiHeadphonesImpl).modelDefinition;
        deviceName = '${modelDef.vendor} ${modelDef.name}';
      }
    }

    final isExtraSmallScreen = screenWidth < 320;
    final isSmallScreen = screenWidth < 400;
    final isWideScreen = screenWidth >= 600;

    // Calcular altura para imagen con proporción menor para evitar scroll
    final imageHeightRatio = isSmallScreen ? 0.14 : (isWideScreen ? 0.18 : 0.15);
    final imageMaxHeight = screenHeight * imageHeightRatio;

    final cardBackgroundColor = theme.colorScheme.surfaceContainerHighest;
    final deviceNameBackgroundColor = theme.colorScheme.primaryContainer.withValues(alpha: 0.9);

    try {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título del dispositivo como sección principal
          Container(
            margin: const EdgeInsets.only(bottom: 12, top: 4),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: deviceNameBackgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              deviceName,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
                fontSize: isExtraSmallScreen ? 18 : (isSmallScreen ? 19 : 20),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Contenedor principal - balance entre imagen y controles
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  // Sección de imagen más compacta
                  if (headphones is HeadphonesModelInfo)
                    Column(
                      children: [
                        Container(
                          height: imageMaxHeight,
                          decoration: BoxDecoration(
                            color: cardBackgroundColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: HeadphonesImage(headphones as HeadphonesModelInfo),
                          ),
                        ),

                        // Botón de configuración como barra debajo de la imagen
                        if (onSettingsTap != null)
                          Container(
                            margin: const EdgeInsets.only(top: 6, bottom: 12),
                            width: double.infinity,
                            height: 40,
                            child: InkWell(
                              onTap: onSettingsTap,
                              borderRadius: BorderRadius.circular(12),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.secondary.withValues(alpha: 0.9),
                                      theme.colorScheme.secondary,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.shadow.withValues(alpha: 0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Symbols.settings,
                                      size: 20,
                                      color: theme.colorScheme.onSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l.pageHeadphonesSettingsTitle,
                                      style: TextStyle(
                                        color: theme.colorScheme.onSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                  // Sección de controles - ocupa el resto del espacio disponible
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardBackgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: isWideScreen
                          ? _buildWideLayout(theme, l, screenWidth)
                          : _buildCompactLayout(context, theme, l, screenWidth, isSmallScreen),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } catch (e, stackTrace) {
      log(LogLevel.error, "Error building content layout", error: e, stackTrace: stackTrace);
      return _buildErrorContent(
        l.headphonesControlNoFeatures,
        l.headphonesControlNoFeaturesDesc,
        l,
        theme: theme,
      );
    }
  }

  Widget _buildWideLayout(ThemeData theme, AppLocalizations l, double screenWidth) {
    final hasAncFeature = headphones is Anc;
    final hasBatteryFeature = headphones is LRCBattery;

    if (!hasAncFeature && !hasBatteryFeature) {
      return _buildErrorContent(
        l.headphonesControlNoFeatures,
        l.headphonesControlNoFeaturesDesc,
        l,
        theme: theme,
      );
    }

    // Para pantallas anchas, usamos un layout más optimizado
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasBatteryFeature) ...[
          // Botón de configuración integrado arriba del BatteryCard
          if (onSettingsTap != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                borderRadius: BorderRadius.circular(12),
                color: theme.colorScheme.secondary,
                elevation: 2,
                child: InkWell(
                  onTap: onSettingsTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Symbols.settings,
                          size: 18,
                          color: theme.colorScheme.onSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l.pageHeadphonesSettingsTitle,
                          style: TextStyle(
                            color: theme.colorScheme.onSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Contenedor de batería optimizado (25% del espacio)
          SizedBox(
            height: 180, // Altura fija para el contenedor de batería
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
              ),
              child: BatteryCard(headphones as LRCBattery),
            ),
          ),
        ],

        const SizedBox(height: 12), // Espaciado entre cards

        if (hasAncFeature)
          // Contenedor de ANC (ocupa el resto del espacio)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AncCard(headphones as Anc),
            ),
          ),
      ],
    );
  }

  Widget _buildCompactLayout(
      BuildContext context, ThemeData theme, AppLocalizations l, double screenWidth, bool isSmallScreen) {
    final hasAncFeature = headphones is Anc;
    final hasBatteryFeature = headphones is LRCBattery;

    if (!hasAncFeature && !hasBatteryFeature) {
      return _buildErrorContent(
        l.headphonesControlNoFeatures,
        l.headphonesControlNoFeaturesDesc,
        l,
        theme: theme,
      );
    }

    // Ajuste de espaciado para diseño compacto
    final verticalSpacing = isSmallScreen ? 8.0 : 10.0;

    return Column(
      children: [
        if (hasBatteryFeature) ...[
          // Botón de configuración integrado encima del BatteryCard
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SizedBox(
              width: double.infinity, // Mismo ancho que BatteryCard
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed('/headphones_settings'),
                icon: Icon(
                  Symbols.settings,
                  size: 20,
                  color: theme.colorScheme.onSecondary,
                ),
                label: Text(
                  l.pageHeadphonesSettingsTitle,
                  style: TextStyle(
                    color: theme.colorScheme.onSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          // Contenedor de batería con altura fija para que no ocupe tanto espacio
          SizedBox(
            height: isSmallScreen ? 130 : 150, // Altura fija más pequeña
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
              ),
              child: BatteryCard(headphones as LRCBattery),
            ),
          ),
        ],

        if (hasAncFeature && hasBatteryFeature) SizedBox(height: verticalSpacing),

        if (hasAncFeature)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AncCard(headphones as Anc),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorContent(String title, String description, AppLocalizations l,
      {required ThemeData theme, Function()? onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.error_outline,
              size: AppDimensions.iconXLarge,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: AppDimensions.spacing16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppDimensions.spacing8),
            Text(
              description,
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.spacing12),
            if (onRetry != null)
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l.headphonesControlRetry),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
