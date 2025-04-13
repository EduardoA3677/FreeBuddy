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
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Builder(
          builder: (context) {
            try {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacing8, vertical: AppDimensions.spacing10) +
                    EdgeInsets.only(bottom: bottomPadding),
                child: _buildMainContent(windowSize, theme, l, screenWidth, screenHeight),
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

    final imageHeightRatio = isSmallScreen ? 0.2 : (isWideScreen ? 0.28 : 0.22);
    final imageMaxHeight = screenHeight * imageHeightRatio;

    try {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surfaceContainerHighest,
              theme.colorScheme.surface,
            ],
            stops: const [0.0, 1.0],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.4),
              blurRadius: AppDimensions.spacing12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withAlpha(220),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withAlpha(50),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  deviceName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: isExtraSmallScreen ? 20 : (isSmallScreen ? 22 : 24),
                  ),
                  textAlign: TextAlign.center,
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.1, end: 0, duration: 500.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 20),
              if (headphones is HeadphonesModelInfo)
                Container(
                  height:
                      isExtraSmallScreen ? 100 : (isSmallScreen ? 130 : (isWideScreen ? 180 : 150)),
                  constraints: BoxConstraints(
                    maxHeight: imageMaxHeight,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withAlpha(220),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withAlpha(60),
                        blurRadius: 12,
                        spreadRadius: 4,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 20),
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
              const SizedBox(height: 20),
              Container(
                margin: EdgeInsets.symmetric(horizontal: isExtraSmallScreen ? 4 : 8, vertical: 16),
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withAlpha(230),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withAlpha(80),
                      blurRadius: 12,
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
            ],
          ),
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
              padding: const EdgeInsets.all(8.0),
              child: BatteryCard(headphones as LRCBattery)
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.005, end: 0, duration: 400.ms),
            ),
          ),
        if (hasAncFeature)
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AncCard(headphones as Anc)
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.005, end: 0, duration: 400.ms),
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
        if (hasBatteryFeature)
          BatteryCard(headphones as LRCBattery)
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms)
              .slideY(begin: -0.05, end: 0, duration: 400.ms),
        const SizedBox(height: 16),
        if (hasAncFeature)
          AncCard(headphones as Anc)
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms)
              .slideY(begin: 0.05, end: 0, duration: 400.ms),
      ],
    );
  }

  Widget _buildErrorContent(String title, String description, AppLocalizations l,
      {required ThemeData theme, Function()? onRetry}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Symbols.error_outline,
            size: AppDimensions.iconXLarge + 8,
            color: theme.colorScheme.error,
          ),
          SizedBox(height: AppDimensions.spacing20),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppDimensions.spacing12),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimensions.spacing16),
          if (onRetry != null)
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l.headphonesControlRetry),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing16, vertical: AppDimensions.spacing12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
