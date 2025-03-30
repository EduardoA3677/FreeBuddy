import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../headphones/framework/low_latency.dart';
import '../../../common/list_tile_switch.dart';

class LowLatencySection extends StatelessWidget {
  final LowLatency headphones;

  const LowLatencySection(this.headphones, {super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return StreamBuilder(
      stream: headphones.lowLatencyEnabled,
      initialData: false,
      builder: (_, snap) {
        return ListTileSwitch(
          title: Text(l.lowLatency),
          subtitle: Text(l.lowLatencyDesc),
          value: snap.data ?? false,
          onChanged: (newVal) => headphones.setLowLatencyEnabled(newVal),
        );
      },
    );
  }
}