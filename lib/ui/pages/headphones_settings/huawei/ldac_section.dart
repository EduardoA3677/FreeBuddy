import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../headphones/framework/headphones_settings.dart';
import '../../../../headphones/huawei/settings.dart';
import '../../../common/list_tile_switch.dart';

class LdacSection extends StatelessWidget {
  final HeadphonesSettings<HuaweiFreeBudsPro3Settings> headphones;

  const LdacSection(this.headphones, {super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return StreamBuilder(
      stream: headphones.settings.map((s) => s.ldac),
      initialData: false,
      builder: (_, snap) {
        return ListTileSwitch(
          title: Text(l.ldac),
          subtitle: Text(l.ldacDesc),
          value: snap.data ?? false,
          onChanged: (newVal) => headphones.setSettings(
            HuaweiFreeBudsPro3Settings(ldac: newVal),
          ),
        );
      },
    );
  }
}