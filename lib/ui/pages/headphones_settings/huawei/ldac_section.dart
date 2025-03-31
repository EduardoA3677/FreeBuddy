import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../headphones/framework/headphones_settings.dart';
import '../../../../headphones/framework/ldac.dart';
import '../../../../headphones/huawei/freebudspro3.dart';
import '../../../../headphones/huawei/settings.dart';
import '../../../common/list_tile_switch.dart';

class LdacSection extends StatelessWidget {
  final HeadphonesSettings<HuaweiFreeBudsPro3Settings> headphones;

  const LdacSection(this.headphones, {super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // Cast headphones to Ldac to use the ldac interface methods
    final ldacHeadphones = headphones as HuaweiFreeBudsPro3;
    
    return StreamBuilder(
      stream: headphones.settings.map((s) => s.ldac),
      initialData: false,
      builder: (_, snap) {
        final ldacEnabled = snap.data ?? false;
        
        return Column(
          children: [
            ListTileSwitch(
              title: Text(l.ldac),
              subtitle: Text(l.ldacDesc),
              value: ldacEnabled,
              onChanged: (newVal) {
                ldacHeadphones.setLdacEnabled(newVal);
                headphones.setSettings(
                  HuaweiFreeBudsPro3Settings(ldac: newVal),
                );
              },
            ),
            if (ldacEnabled)
              StreamBuilder<LdacMode>(
                stream: ldacHeadphones.ldacMode,
                initialData: LdacMode.quality,
                builder: (context, snapshot) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<LdacMode>(
                            decoration: InputDecoration(
                              labelText: "LDAC Mode",
                              border: OutlineInputBorder(),
                            ),
                            value: snapshot.data,
                            onChanged: (LdacMode? newValue) {
                              if (newValue != null) {
                                ldacHeadphones.setLdacMode(newValue);
                                headphones.setSettings(
                                  HuaweiFreeBudsPro3Settings(ldacMode: newValue),
                                );
                              }
                            },
                            items: LdacMode.values
                                .map<DropdownMenuItem<LdacMode>>((LdacMode value) {
                              return DropdownMenuItem<LdacMode>(
                                value: value,
                                child: Text(value == LdacMode.connectivity
                                    ? 'Connectivity (Better Stability)'
                                    : 'Quality (Better Sound)'),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
