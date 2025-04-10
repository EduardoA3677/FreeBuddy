import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../headphones/framework/anc.dart';
import '../../../../headphones/framework/bluetooth_headphones.dart';
import '../../../../headphones/framework/headphones_info.dart';
import '../../../../headphones/framework/lrc_battery.dart';
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

    final contentWidgets = <Widget>[];

    // Añadir imagen de auriculares si hay información del modelo
    if (headphones is HeadphonesModelInfo) {
      contentWidgets.add(
        LayoutBuilder(
          builder: (context, constraints) {
            // Imagen responsiva según el tamaño de pantalla
            final imageHeight = constraints.maxWidth > 600 ? 180.0 : 150.0;
            return Container(
              height: imageHeight,
              margin: const EdgeInsets.only(bottom: 16),
              child: HeadphonesImage(headphones as HeadphonesModelInfo)
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1.0, 1.0),
                      duration: 500.ms,
                      curve: Curves.easeOutQuad),
            );
          },
        ),
      );
    }

    // Agregar las funciones (sincrónicas)
    void addBatteryFeature() {
      if (headphones is LRCBattery) {
        log(LogLevel.debug, "Adding battery feature");
        contentWidgets.add(
          FractionallySizedBox(
            widthFactor: screenWidth > 600 ? 0.8 : 0.98,
            child: BatteryCard(headphones as LRCBattery)
                .animate()
                .fadeIn(duration: 800.ms, delay: 200.ms)
                .slideY(begin: 0.05, end: 0, duration: 600.ms, curve: Curves.easeOutQuad),
          ),
        );
      }
    }

    void addANCFeature() {
      if (headphones is Anc) {
        log(LogLevel.debug, "Adding ANC feature");
        contentWidgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FractionallySizedBox(
              widthFactor: screenWidth > 600 ? 0.8 : 0.98,
              child: AncCard(headphones as Anc)
                  .animate()
                  .fadeIn(duration: 800.ms, delay: 400.ms)
                  .slideY(begin: 0.05, end: 0, duration: 600.ms, curve: Curves.easeOutQuad),
            ),
          ),
        );
      }
    }

    try {
      // Añadir funciones secuencialmente
      addBatteryFeature();
      addANCFeature();
    } catch (e, stackTrace) {
      log(LogLevel.error, "Error loading feature cards", error: e, stackTrace: stackTrace);
    }

    if (contentWidgets.isEmpty) {
      return _buildErrorContent(
        l.headphonesControlNoFeatures,
        l.headphonesControlNoFeaturesDesc,
        l,
        theme: theme,
      );
    }

    // Si tenemos widgets de contenido, mostrarlos en un ListView
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: contentWidgets,
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
