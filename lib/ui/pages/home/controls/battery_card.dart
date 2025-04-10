import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../gen/freebuddy_icons.dart';
import '../../../../headphones/framework/lrc_battery.dart';
import '../../../../headphones/huawei/features/battery_feature.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate responsive font sizes based on screen width
    final titleSize = screenWidth < 360 ? 16.0 : 18.0;
    final fontSize = screenWidth < 360 ? 14.0 : 16.0;

    return StreamBuilder<LRCBatteryLevels>(
      stream: lrcBattery is BatteryFeature
          ? (lrcBattery as BatteryFeature).batteryLevels
          : lrcBattery.lrcBattery,
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
                    fontSize: titleSize,
                  ),
                ),
                const SizedBox(height: 16),
                BatteryBox(
                  icon: FreebuddyIcons.leftEarbud,
                  text: 'Left Earbud',
                  level: levels?.levelLeft,
                  charging: levels?.chargingLeft ?? false,
                  fontSize: fontSize,
                ),
                const SizedBox(height: 8),
                BatteryBox(
                  icon: FreebuddyIcons.rightEarbud,
                  text: 'Right Earbud',
                  level: levels?.levelRight,
                  charging: levels?.chargingRight ?? false,
                  fontSize: fontSize,
                ),
                const SizedBox(height: 8),
                BatteryBox(
                  icon: FreebuddyIcons.earbudsCase,
                  text: 'Case',
                  level: levels?.levelCase,
                  charging: levels?.chargingCase ?? false,
                  fontSize: fontSize,
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
  final double fontSize;

  const BatteryBox({
    required this.icon,
    required this.text,
    required this.level,
    required this.charging,
    this.fontSize = 16.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Choose battery color based on level
    Color getBatteryColor() {
      if (level == null) return Colors.grey;
      if (level! < 20) return Colors.red;
      if (level! < 50) return Colors.orange;
      return Colors.green;
    }

    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: fontSize,
            ),
          ),
        ),
        Text(
          level != null ? '$level%' : '--%',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            color: getBatteryColor(),
          ),
        ),
        if (charging)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(
              Symbols.bolt,
              size: fontSize,
              color: Colors.green,
            ),
          ),
      ],
    );
  }
}
