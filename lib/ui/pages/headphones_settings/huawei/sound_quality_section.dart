import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../headphones/framework/sound_quality.dart';
import '../../../common/list_tile_switch.dart';

class SoundQualitySection extends StatelessWidget {
  final SoundQuality headphones;

  const SoundQualitySection(this.headphones, {super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return StreamBuilder(
      stream: headphones.soundQuality,
      initialData: SoundQualityPreference.connectivity,
      builder: (_, snap) {
        final isHighQuality = snap.data == SoundQualityPreference.quality;
        return ListTileSwitch(
          title: Text(l.soundQuality),
          subtitle: Text(isHighQuality ? l.soundQualityQuality : l.soundQualityConnectivity),
          value: isHighQuality,
          onChanged: (isHighQuality) => headphones.setSoundQuality(
            isHighQuality ? SoundQualityPreference.quality : SoundQualityPreference.connectivity,
          ),
        );
      },
    );
  }
}