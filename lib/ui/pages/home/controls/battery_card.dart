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
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
                BatteryBox(
                  icon: FreebuddyIcons.leftEarbud,
                  text: 'Left Earbud',
                  level: levels?.levelLeft,
                  charging: levels?.chargingLeft ?? false,
                ),
                const SizedBox(height: 8),
                BatteryBox(
                  icon: FreebuddyIcons.rightEarbud,
                  text: 'Right Earbud',
                  level: levels?.levelRight,
                  charging: levels?.chargingRight ?? false,
                ),
                const SizedBox(height: 8),
                BatteryBox(
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
}

class BatteryBox extends StatelessWidget {
  final IconData icon;
  final String text;
  final int? level;
  final bool charging;

  const BatteryBox({
    required this.icon,
    required this.text,
    required this.level,
    required this.charging,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Text(
          level != null ? '$level%' : '--%',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (charging)
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Icon(
              Symbols.bolt,
              size: 16,
              color: Colors.green,
            ),
          ),
      ],
    );
  }
}
