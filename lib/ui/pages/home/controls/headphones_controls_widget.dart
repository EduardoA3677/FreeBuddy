import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../headphones/framework/anc.dart';
import '../../../../headphones/framework/bluetooth_headphones.dart';
import '../../../../headphones/framework/headphones_settings.dart';
import '../../../../headphones/framework/lrc_battery.dart';
import '../../../../logger.dart';
import '../../../theme/layouts.dart';
import 'anc_card.dart';
import 'battery_card.dart';

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
                  _buildHeader(textTheme, l),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildMainContent(windowSize, theme, l),
                  ),
                  if (headphones is HeadphonesSettings) ...[
                    const SizedBox(height: 16),
                    _buildSettingsButton(context, l),
                  ],
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

  Widget _buildHeader(TextTheme textTheme, AppLocalizations l) {
    return Text(
      l.headphonesControl,
      style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildMainContent(WindowSizeClass windowSize, ThemeData theme, AppLocalizations l) {
    log(LogLevel.debug, "Building main content for headphones: ${headphones.runtimeType}");

    final contentWidgets = <Widget>[];

    // Synchronously add features since they're UI-only operations
    void addBatteryFeature() {
      if (headphones is LRCBattery) {
        log(LogLevel.debug, "Adding battery feature");
        contentWidgets.add(BatteryCard(headphones as LRCBattery));
      }
    }

    void addANCFeature() {
      if (headphones is Anc) {
        log(LogLevel.debug, "Adding ANC feature");
        contentWidgets.add(AncCard(headphones as Anc));
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
}
