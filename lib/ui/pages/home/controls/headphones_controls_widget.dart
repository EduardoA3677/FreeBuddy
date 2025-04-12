import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import 'anc_card.dart';
import 'battery_card.dart';
import 'headphones_image.dart';

/// Widget principal con controles para auriculares
///
/// Contiene indicadores de batería, botones de ANC, configuración, etc.
/// Solo necesita recibir el objeto [headphones] para mostrar toda la información
class HeadphonesControlsWidget extends StatelessWidget {
  final BluetoothHeadphones headphones;

  const HeadphonesControlsWidget({super.key, required this.headphones});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final windowSize = WindowSizeClass.of(context);
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    final screenWidth = MediaQuery.of(context).size.width;
    final l = AppLocalizations.of(context)!;

    return SafeArea(
      child: Builder(
        builder: (context) {
          try {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(12.0) + EdgeInsets.only(bottom: bottomPadding),
              child: _buildMainContent(windowSize, theme, l, screenWidth),
            );
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
      ),
    );
  }

  Widget _buildMainContent(
      WindowSizeClass windowSize, ThemeData theme, AppLocalizations l, double screenWidth) {
    log(LogLevel.debug, "Building main content for headphones: ${headphones.runtimeType}");

    // Dispositivo Huawei info
    HuaweiModelDefinition? modelDef;
    String deviceName = "";

    if (headphones is HuaweiHeadphonesBase) {
      if (headphones is HuaweiHeadphonesImpl) {
        modelDef = (headphones as HuaweiHeadphonesImpl).modelDefinition;
        deviceName = '${modelDef.vendor} ${modelDef.name}';
      }
    }

    // Determina si es pantalla pequeña
    final isSmallScreen = screenWidth < 400;
    final isWideScreen = screenWidth > 600;

    try {
      // Usar un diseño fixed sin scrolling con un contenedor estilizado
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.scaffoldBackgroundColor,
            ],
            stops: const [0.0, 1.0],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            // Device Name with modern styling and badge
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                deviceName,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: -0.1, end: 0, duration: 500.ms, curve: Curves.easeOutBack),

            const SizedBox(height: 20),

            // Headphones Image with improved container
            if (headphones is HeadphonesModelInfo)
              Flexible(
                flex: isSmallScreen ? 2 : 3,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: isSmallScreen ? 140 : (isWideScreen ? 200 : 170),
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: HeadphonesImage(headphones as HeadphonesModelInfo)
                        .animate()
                        .fadeIn(duration: 800.ms)
                        .scale(
                          begin: const Offset(0.85, 0.85),
                          end: const Offset(1.0, 1.0),
                          duration: 800.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Main Content Area with card-like container
            Expanded(
              flex: isSmallScreen ? 7 : 6,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.07),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: isWideScreen
                    ? _buildWideLayout(theme, l, screenWidth)
                    : _buildCompactLayout(theme, l, screenWidth, isSmallScreen),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms)
                  .slideY(begin: 0.1, end: 0, duration: 500.ms),
            ),
          ],
        ),
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

  // Layout for wider screens - cards side by side
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasBatteryFeature)
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: BatteryCard(headphones as LRCBattery)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideX(begin: -0.05, end: 0, duration: 400.ms),
            ),
          ),
        if (hasAncFeature)
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AncCard(headphones as Anc)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideX(begin: 0.05, end: 0, duration: 400.ms),
            ),
          ),
      ],
    );
  }

  // Layout for smaller screens - cards stacked with minimized heights
  Widget _buildCompactLayout(
      ThemeData theme, AppLocalizations l, double screenWidth, bool isSmallScreen) {
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

    return Column(
      children: [
        if (hasBatteryFeature)
          Expanded(
            flex: isSmallScreen ? 1 : 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: BatteryCard(headphones as LRCBattery)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideY(begin: 0.05, end: 0, duration: 400.ms),
            ),
          ),
        if (hasAncFeature)
          Expanded(
            flex: isSmallScreen ? 1 : 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: AncCard(headphones as Anc)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms)
                  .slideY(begin: 0.05, end: 0, duration: 400.ms),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorContent(
    String title,
    String message,
    AppLocalizations l, {
    VoidCallback? onRetry,
    required ThemeData theme,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Symbols.headset_off,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 204),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Symbols.refresh),
                    label: Text(l.headphonesControlRetry),
                  ),
                ],
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms)
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), duration: 300.ms),
      ),
    );
  }
}
