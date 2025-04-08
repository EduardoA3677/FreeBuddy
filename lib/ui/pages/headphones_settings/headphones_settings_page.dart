import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../headphones/framework/bluetooth_headphones.dart';
import '../../../headphones/huawei/huawei_headphones_base.dart';
import '../../../headphones/huawei/huawei_headphones_impl.dart';
import '../../../headphones/model_definition/huawei_models_definition.dart';
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
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l.pageHeadphonesSettingsTitle),
        backgroundColor: Theme.of(context)
            .colorScheme
            .surface
            .withAlpha(242), // ~0.95 opacity
        elevation: 0,
      ),
      body: SafeArea(
        top: false, // No aplicar padding superior ya que el AppBar lo maneja
        child: Center(
          child: HeadphonesConnectionEnsuringOverlay(
            builder: (_, h) => ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              children: _buildSettingsWidgets(h),
            ),
          ),
        ),
      ),
    );
  }
}

/// Builds appropriate settings widgets based on headphone model
List<Widget> _buildSettingsWidgets(BluetoothHeadphones headphones) {
  if (headphones is HuaweiHeadphonesBase) {
    final huaweiBase = headphones;
    HuaweiModelDefinition? modelDef;

    if (headphones is HuaweiHeadphonesImpl) {
      modelDef = (headphones).modelDefinition;
    }

    final sections = <Widget>[];

    // Add auto-pause section if supported
    if (modelDef?.supportsAutoPause ?? false) {
      sections.add(AutoPauseSection(huaweiBase));
      sections.add(const Divider(indent: 16, endIndent: 16));
    }

    // Add double-tap section if supported
    if (modelDef?.supportsDoubleTap ?? true) {
      // Default to true for compatibility
      sections.add(DoubleTapSection(huaweiBase));
      sections.add(const Divider(indent: 16, endIndent: 16));
    }

    // Add hold section if supported
    if (modelDef?.supportsHold ?? true) {
      // Default to true for compatibility
      sections.add(HoldSection(huaweiBase));
    }

    sections.add(const SizedBox(height: 64));
    return sections;
  } else {
    throw "You shouldn't be on this screen if you don't have settings!";
  }
}
