import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../gen/freebuddy_icons.dart';
import '../../../../headphones/framework/lrc_battery.dart';

/// Android12-Google-Battery-Widget-style battery card
///
/// https://9to5google.com/2022/03/07/google-pixel-battery-widget/
/// https://9to5google.com/2022/09/29/pixel-battery-widget-time/
class BatteryCard extends StatelessWidget {
  final LRCBattery lrcBattery;

  const BatteryCard(this.lrcBattery, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return StreamBuilder<LRCBatteryLevels>(
      stream: lrcBattery.lrcBattery,
      builder: (context, snapshot) {
        final levels = snapshot.data;
        return Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Battery',
                  style: textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildBatteryBox(
                  context,
                  icon: FreebuddyIcons.leftEarbud,
                  text: 'Left Earbud',
                  level: levels?.levelLeft,
                  charging: levels?.chargingLeft ?? false,
                ),
                const SizedBox(height: 8),
                _buildBatteryBox(
                  context,
                  icon: FreebuddyIcons.rightEarbud,
                  text: 'Right Earbud',
                  level: levels?.levelRight,
                  charging: levels?.chargingRight ?? false,
                ),
                const SizedBox(height: 8),
                _buildBatteryBox(
                  context,
                  icon: FreebuddyIcons.earbudsCase,
                  text: 'Case',
                  level: levels?.levelCase,
                  charging: levels?.chargingCase ?? false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBatteryBox(
    BuildContext context, {
    required IconData icon,
    required String text,
    required int? level,
    required bool? charging,
  }) {
    return _BatteryContainer(
      value: level != null ? level / 100 : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween<double>(
                    begin: 0.5,
                    end: charging == true ? 1.0 : 0.5,
                  ),
                  builder: (context, value, child) => Icon(
                    icon,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary.withAlpha((value * 255).round()),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    '${level ?? '-'}%',
                    key: ValueKey(level),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                if (charging == true) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Symbols.charger,
                    fill: 1,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BatteryContainer extends StatelessWidget {
  final double? value;
  final Widget child;

  const _BatteryContainer({
    required this.value,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha((0.3 * 255).round()),
      ),
      child: Stack(
        children: [
          if (value != null)
            Positioned.fill(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withAlpha((0.15 * 255).round()),
                    ),
                  ),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}
