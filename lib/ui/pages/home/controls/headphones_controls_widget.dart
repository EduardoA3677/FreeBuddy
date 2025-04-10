import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../headphones/framework/anc.dart';
import '../../../../headphones/framework/bluetooth_headphones.dart';
import '../../../../headphones/framework/headphones_settings.dart';
import '../../../../headphones/framework/lrc_battery.dart';
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(12.0) + EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        children: [
          _buildHeader(textTheme),
          const SizedBox(height: 16),
          Expanded(
            child: _buildMainContent(windowSize),
          ),
          if (headphones is HeadphonesSettings) ...[
            const SizedBox(height: 16),
            _buildSettingsButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    return Text(
      'Headphones Controls',
      style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildMainContent(WindowSizeClass windowSize) {
    return ListView(
      children: [
        if (headphones is LRCBattery) BatteryCard(headphones as LRCBattery),
        if (headphones is Anc) AncCard(headphones as Anc),
        // Add more cards or widgets as needed
      ],
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => GoRouter.of(context).push('/settings'),
      icon: const Icon(Icons.settings),
      label: const Text('Settings'),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
