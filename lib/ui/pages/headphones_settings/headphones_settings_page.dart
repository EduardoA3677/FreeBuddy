import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../headphones/framework/headphones_settings.dart';
import '../../../headphones/huawei/features/settings.dart';
import '../../../headphones/model_definition/huawei_model_definition.dart';
import '../../common/headphones_connection_ensuring_overlay.dart';
import 'huawei/auto_pause_section.dart';
import 'huawei/double_tap_section.dart';
import 'huawei/hold_section.dart';

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

// This builds settings sections based on headphones type and capabilities
List<Widget> widgetsForModel(HeadphonesSettings settings) {
  if (settings is HuaweiHeadphonesBase) {
    final huaweiSettings =
        settings as HeadphonesSettings<HuaweiHeadphonesSettings>;
    final model = (settings as HuaweiHeadphonesImpl).modelDefinition;

    final sections = <Widget>[];

    // Add auto-pause section if supported
    if (model.supportsAutoPause) {
      sections.add(AutoPauseSection(huaweiSettings));
      sections.add(const Divider(indent: 16, endIndent: 16));
    }

    // Add double-tap section if supported
    if (model.supportsDoubleTap) {
      sections.add(DoubleTapSection(huaweiSettings));
      sections.add(const Divider(indent: 16, endIndent: 16));
    }

    // Add hold section if supported
    if (model.supportsHold) {
      sections.add(HoldSection(huaweiSettings));
    }

    sections.add(const SizedBox(height: 64));
    return sections;
  } else {
    throw "You shouldn't be on this screen if you don't have settings!";
  }
}
