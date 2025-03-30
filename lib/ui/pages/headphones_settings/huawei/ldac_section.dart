import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../headphones/framework/ldac.dart';
import '../../../common/list_tile_switch.dart';

class LdacSection extends StatelessWidget {
  final Ldac headphones;

  const LdacSection(this.headphones, {super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return StreamBuilder(
      stream: headphones.ldacEnabled,
      initialData: false,
      builder: (_, snap) {
        return ListTileSwitch(
          title: Text(l.ldac),
          subtitle: Text(l.ldacDesc),
          value: snap.data ?? false,
          onChanged: (newVal) => headphones.setLdacEnabled(newVal),
        );
      },
    );
  }
}