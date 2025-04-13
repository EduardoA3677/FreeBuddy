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
import 'anc_card.dart';
import 'battery_card.dart';
import 'headphones_image.dart';

class HeadphonesControlsWidget extends StatelessWidget {
  final BluetoothHeadphones headphones;

  const HeadphonesControlsWidget({super.key, required this.headphones});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    HuaweiModelDefinition? modelDef;
    String deviceName = "";

    if (headphones is HuaweiHeadphonesImpl) {
      modelDef = (headphones as HuaweiHeadphonesImpl).modelDefinition;
      deviceName = '${modelDef.vendor} ${modelDef.name}';
    }

    final isSmallScreen = screenWidth < 400;
    final isWideScreen = screenWidth >= 600;
    final imageHeightRatio = isSmallScreen ? 0.2 : (isWideScreen ? 0.28 : 0.22);
    final imageMaxHeight = screenHeight * imageHeightRatio;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  deviceName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (headphones is HeadphonesModelInfo)
                  Container(
                    height: imageMaxHeight,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: HeadphonesImage(headphones as HeadphonesModelInfo),
                    ),
                  ),
                const SizedBox(height: 20),
                _buildFeatureCards(theme, l, isWideScreen),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCards(ThemeData theme, AppLocalizations l, bool isWideScreen) {
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

    List<Widget> cards = [];
    if (hasBatteryFeature) {
      cards.add(
        Card(
          color: theme.colorScheme.surface,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: BatteryCard(headphones: headphones as LRCBattery),
          ),
        ),
      );
    }

    if (hasAncFeature) {
      cards.add(
        Card(
          color: theme.colorScheme.surface,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: AncCard(headphones: headphones as Anc),
          ),
        ),
      );
    }

    return isWideScreen
        ? Row(
            children: cards
                .map((card) => Expanded(child: Padding(padding: const EdgeInsets.all(8), child: card)))
                .toList(),
          )
        : Column(
            children: cards
                .map((card) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: card))
                .toList(),
          );
  }

  Widget _buildErrorContent(String title, String message, AppLocalizations l, {required ThemeData theme}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Symbols.warning, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onBackground),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
