import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../headphones/framework/anc.dart';
import '../../../../headphones/framework/bluetooth_headphones.dart';
import '../../../../headphones/framework/headphones_info.dart';
import '../../../../headphones/framework/headphones_settings.dart';
import '../../../../headphones/framework/lrc_battery.dart';
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StreamBuilder(
          stream: headphones.bluetoothAlias,
          builder: (_, snap) => Text(
            snap.data ?? headphones.bluetoothName,
            style: textTheme.headlineMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(WindowSizeClass windowSize) {
    final isCompact = windowSize == WindowSizeClass.compact;
    final children = [
      if (headphones is HeadphonesModelInfo)
        Flexible(
          flex: isCompact ? 0 : 1,
          child: HeadphonesImage(headphones as HeadphonesModelInfo),
        ),
      if (isCompact) const SizedBox(height: 24),
      Flexible(
        flex: isCompact ? 0 : 1,
        child: _buildControls(isCompact),
      ),
    ];

    return isCompact
        ? Column(children: children)
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          );
  }

  Widget _buildControls(bool isCompact) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final children = <Widget>[
          if (headphones is LRCBattery) BatteryCard(headphones as LRCBattery),
          if (headphones is Anc) ...[
            SizedBox(height: isCompact ? 16 : 0, width: isCompact ? 0 : 16),
            AncCard(headphones as Anc),
          ],
        ];

        return isCompact
            ? Column(children: children)
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children.map((child) => Expanded(child: child)).toList(),
              );
      },
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.settings),
      label: Text('Settings'), // Using hardcoded string until l10n is fixed
      onPressed: () => GoRouter.of(context).push('/headphones_settings'),
    );
  }
}
