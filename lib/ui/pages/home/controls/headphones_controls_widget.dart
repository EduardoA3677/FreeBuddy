import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../headphones/framework/anc.dart';
import '../../../../headphones/framework/bluetooth_headphones.dart';
import '../../../../headphones/framework/headphones_info.dart';
import '../../../../headphones/framework/headphones_settings.dart';
import '../../../../headphones/framework/lrc_battery.dart';
import '../../../../logger.dart';
import '../../../app_settings.dart';
import '../../../theme/layouts.dart';
import 'anc_card.dart';
import 'battery_card.dart';
import 'headphones_image.dart';

/// Main whole-screen widget with controls for headphones
///
/// It contains battery, anc buttons, button to settings etc - just give it
/// the [headphones] and all done ☺
///
/// ...in fact, it is built so simple that you can freely hot-swap the
/// headphones object - for example, if they disconnect for a moment,
/// you can give it [HeadphonesMockNever] object, and previous values will stay
/// because it won't override them
class HeadphonesControlsWidget extends StatelessWidget {
  final BluetoothHeadphones headphones;

  const HeadphonesControlsWidget({super.key, required this.headphones});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
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
              child: Column(
                children: [
                  _buildAppBar(context, textTheme, l),
                  const SizedBox(height: 16),
                  if (headphones is HeadphonesModelInfo) ...[
                    _buildModelHeader(headphones as HeadphonesModelInfo, textTheme),
                    const SizedBox(height: 16),
                  ],
                  Expanded(
                    child: _buildMainContent(windowSize, theme, l, screenWidth),
                  ),
                ],
              ),
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

  Widget _buildAppBar(BuildContext context, TextTheme textTheme, AppLocalizations l) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l.headphonesControl,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: l.settings,
          onPressed: () {
            // Open app settings
            showDialog(
              context: context,
              builder: (context) => _buildAppSettingsDialog(context, l),
            );
          },
        ),
      ],
    );
  }

  Widget _buildModelHeader(HeadphonesModelInfo modelInfo, TextTheme textTheme) {
    return Text(
      "${modelInfo.vendor} ${modelInfo.name}",
      style: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMainContent(
      WindowSizeClass windowSize, ThemeData theme, AppLocalizations l, double screenWidth) {
    log(LogLevel.debug, "Building main content for headphones: ${headphones.runtimeType}");

    final contentWidgets = <Widget>[];

    // Add headphones image if model info is available
    if (headphones is HeadphonesModelInfo) {
      contentWidgets.add(
        LayoutBuilder(
          builder: (context, constraints) {
            // Make image responsive to screen size
            final imageHeight = constraints.maxWidth > 600 ? 180.0 : 150.0;
            return Container(
              height: imageHeight,
              margin: const EdgeInsets.only(bottom: 16),
              child: HeadphonesImage(headphones as HeadphonesModelInfo),
            );
          },
        ),
      );
    }

    // Add settings button if available (using Builder to get context)
    if (headphones is HeadphonesSettings) {
      contentWidgets.add(
        Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildSettingsButton(context, l),
          ),
        ),
      );
    }

    // Synchronously add features since they're UI-only operations
    void addBatteryFeature() {
      if (headphones is LRCBattery) {
        log(LogLevel.debug, "Adding battery feature");
        contentWidgets.add(
          FractionallySizedBox(
            widthFactor: screenWidth > 600 ? 0.8 : 0.95,
            child: BatteryCard(headphones as LRCBattery),
          ),
        );
      }
    }

    void addANCFeature() {
      if (headphones is Anc) {
        log(LogLevel.debug, "Adding ANC feature");
        contentWidgets.add(
          FractionallySizedBox(
            widthFactor: screenWidth > 600 ? 0.8 : 0.95,
            child: AncCard(headphones as Anc),
          ),
        );
      }
    }

    try {
      // Add features sequentially since they're sync operations
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

    return ListView(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.headphones_outlined,
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
                color: theme.colorScheme.onSurface.withAlpha(204),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l.headphonesControlRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context, AppLocalizations l) {
    return ElevatedButton.icon(
      onPressed: () => GoRouter.of(context).push('/headphones_settings'),
      icon: const Icon(Icons.settings),
      label: Text(l.settings),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildAppSettingsDialog(BuildContext context, AppLocalizations l) {
    final appSettings = Provider.of<AppSettings>(context, listen: false);

    return AlertDialog(
      title: Text(l.settings),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sleep mode toggle
          StreamBuilder<bool>(
            stream: appSettings.sleepMode,
            builder: (context, snapshot) {
              final sleepModeEnabled = snapshot.data ?? false;
              return SwitchListTile(
                title: const Text('Sleep Mode'),
                value: sleepModeEnabled,
                onChanged: (value) {
                  appSettings.setSleepMode(value);
                },
              );
            },
          ),
          // Add more app settings here as needed
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
