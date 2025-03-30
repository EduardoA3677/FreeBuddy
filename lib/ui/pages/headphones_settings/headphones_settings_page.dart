import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../headphones/framework/headphones_settings.dart';
import '../../../headphones/framework/low_latency.dart';
import '../../../headphones/framework/ldac.dart';
import '../../../headphones/huawei/settings.dart';
import '../../common/headphones_connection_ensuring_overlay.dart';
import 'huawei/auto_pause_section.dart';
import 'huawei/double_tap_section.dart';
import 'huawei/hold_section.dart';
import 'huawei/ldac_section.dart';
import 'huawei/low_latency_section.dart';

class HeadphonesSettingsPage extends StatelessWidget {
  const HeadphonesSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.pageHeadphonesSettingsTitle)),
      body: Center(
        child: HeadphonesConnectionEnsuringOverlay(
          builder: (_, h) =>
              ListView(children: widgetsForModel(h as HeadphonesSettings)),
        ),
      ),
    );
  }
}

// this is shitty. and we don't want this. not here.
// ...
// but i have no better idea for now :)))))
List<Widget> widgetsForModel(HeadphonesSettings settings) {
  if (settings is HeadphonesSettings<HuaweiFreeBudsPro3Settings>) {
    // Como HuaweiFreeBudsPro3 implementa LowLatency, podemos hacer cast a LowLatency
    final lowLatencySettings = settings as LowLatency;
    final ldacSettings = settings as Ldac;
    return [
      AutoPauseSection(settings),
      const Divider(indent: 16, endIndent: 16),
      LdacSection(ldacSettings),
      const Divider(indent: 16, endIndent: 16),
      LowLatencySection(lowLatencySettings),
      const Divider(indent: 16, endIndent: 16),
      DoubleTapSection(settings),
      const Divider(indent: 16, endIndent: 16),
      HoldSection(settings),
      const SizedBox(height: 64),
    ];
  } else {
    throw "You shouldn't be on this screen if you don't have settings!";
  }
}
