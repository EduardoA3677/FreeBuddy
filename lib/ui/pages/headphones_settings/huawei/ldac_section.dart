import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../headphones/framework/headphones_settings.dart';
import '../../../../headphones/framework/ldac.dart';
import '../../../../headphones/huawei/settings.dart';
import '../../../common/list_tile_switch.dart';

class LdacSection extends StatelessWidget {
  final HeadphonesSettings<HuaweiFreeBudsPro3Settings> headphones;

  const LdacSection(this.headphones, {super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // Cast headphones to Ldac to use the ldac interface methods
    final ldacHeadphones = headphones as Ldac;
    
    return StreamBuilder<bool>(
      stream: ldacHeadphones.ldac,
      initialData: false,
      builder: (_, snap) {
        final ldacEnabled = snap.data ?? false;
        
        return ListTileSwitch(
          title: Text(l.ldac),
          subtitle: Text(l.ldacDesc),
          value: ldacEnabled,
          onChanged: (newVal) {
            ldacHeadphones.setLdac(newVal);
          },
        );
      },
    );
  }
}
