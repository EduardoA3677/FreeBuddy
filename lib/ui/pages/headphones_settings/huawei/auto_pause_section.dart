import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../headphones/huawei/features/settings.dart';
import '../../../../headphones/huawei/huawei_headphones_base.dart';
import '../../../common/list_tile_switch.dart';

class AutoPauseSection extends StatelessWidget {
  final HuaweiHeadphonesBase headphones;

  const AutoPauseSection(this.headphones, {super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return StreamBuilder(
      stream: headphones.settings.map((s) => s.autoPause),
      initialData: false,
      builder: (_, snap) {
        return ListTileSwitch(
          title: Text(l.autoPause),
          subtitle: Text(l.autoPauseDesc),
          value: snap.data ?? false,
          onChanged: (newVal) => headphones.setSettings(
            HuaweiHeadphonesSettings(autoPause: newVal),
          ),
        );
      },
    );
  }
}
