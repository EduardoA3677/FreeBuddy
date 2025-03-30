import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../headphones/framework/headphones_settings.dart';
import '../../../../headphones/huawei/settings.dart';
import '../../../common/list_tile_switch.dart';

class LowLatencySection extends StatelessWidget {
  final HeadphonesSettings<HuaweiFreeBudsPro3Settings> headphones;

  const LowLatencySection(this.headphones, {super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return StreamBuilder(
      stream: headphones.settings.map((s) => (lowLatency: s.lowLatency)),
      initialData: (lowLatency: false),
      builder: (_, snap) {
        final gs = snap.data!;
        return ListTileSwitch(
          title: Text(l.lowLatency),
          subtitle: Text(l.lowLatencyDesc),
          value: gs.lowLatency ?? false,
          onChanged: (newVal) => headphones.setSettings(
                HuaweiFreeBudsPro3Settings(
                  lowLatency: newVal,
                ),
              ),
        );
      },
    );
  }
}