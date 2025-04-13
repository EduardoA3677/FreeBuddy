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

  const HeadphonesControlsWidget({super.key, required this.headphones});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final windowSize = WindowSizeClass.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Builder(
          builder: (context) {
            try {
              return _buildMainContent(windowSize, theme, l, screenWidth, screenHeight);
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
      ),
    );
  }

  Widget _buildMainContent(WindowSizeClass windowSize, ThemeData theme, AppLocalizations l,
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

    final imageHeightRatio = isSmallScreen ? 0.18 : (isWideScreen ? 0.24 : 0.2);
    final imageMaxHeight = screenHeight * imageHeightRatio;

    try {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Card(
                elevation: 2,
                color: theme.colorScheme.primaryContainer,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    deviceName,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                      fontSize: isExtraSmallScreen ? 18 : (isSmallScreen ? 20 : 22),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (headphones is HeadphonesModelInfo)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
                child: Card(
                  elevation: 3,
                  surfaceTintColor: Colors.transparent,
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: imageMaxHeight,
                    ),
                    child: SizedBox(
                      height: isExtraSmallScreen ? 90 : (isSmallScreen ? 120 : (isWideScreen ? 160 : 140)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: HeadphonesImage(headphones as HeadphonesModelInfo),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
              child: Card(
                elevation: 2,
                surfaceTintColor: Colors.transparent,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  child: isWideScreen
                      ? _buildWideLayout(theme, l, screenWidth)
                      : _buildCompactLayout(theme, l, screenWidth, isSmallScreen),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasBatteryFeature)
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: BatteryCard(headphones as LRCBattery),
            ),
          ),
        if (hasAncFeature)
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: AncCard(headphones as Anc),
            ),
          ),
      ],
    );
  }

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
        if (hasBatteryFeature) BatteryCard(headphones as LRCBattery),
        if (hasAncFeature && hasBatteryFeature) const SizedBox(height: 12),
        if (hasAncFeature) AncCard(headphones as Anc),
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
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
