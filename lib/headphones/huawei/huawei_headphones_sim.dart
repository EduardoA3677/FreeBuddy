import 'package:rxdart/rxdart.dart';

import '../model_definition/huawei_models_definition.dart';
import '../simulators/anc_sim.dart';
import '../simulators/bluetooth_headphones_sim.dart';
import '../simulators/lrc_battery_sim.dart';
import '../simulators/sound_quality_sim.dart';
import 'features/settings.dart';
import 'huawei_headphones_base.dart';

/// Simulator for Huawei headphones
class HuaweiHeadphonesSim extends HuaweiHeadphonesBase
    with BluetoothHeadphonesSim, LRCBatteryAlwaysFullSim, AncSim, SoundQualitySim {
  final HuaweiModelDefinition model;
  final _settingsCtrl = BehaviorSubject<HuaweiHeadphonesSettings>();

  HuaweiHeadphonesSim(this.model) {
    _settingsCtrl.add(model.defaultSettings);
  }

  // No necesita ser @override ya que estamos implementando este método, no sobrescribiéndolo
  void dispose() {
    _settingsCtrl.close();
    disposeSoundQuality();
  }

  @override
  String get name => model.name;

  @override
  ValueStream<String> get imageAssetPath => BehaviorSubject.seeded(model.imageAssetPath);

  @override
  ValueStream<HuaweiHeadphonesSettings> get settings => _settingsCtrl.stream;

  @override
  Future<void> setSettings(HuaweiHeadphonesSettings newSettings) async {
    final prev = _settingsCtrl.value;

    _settingsCtrl.add(HuaweiHeadphonesSettings(
      doubleTapLeft: newSettings.doubleTapLeft ?? prev.doubleTapLeft,
      doubleTapRight: newSettings.doubleTapRight ?? prev.doubleTapRight,
      holdBoth: newSettings.holdBoth ?? prev.holdBoth,
      holdBothToggledAncModes: newSettings.holdBothToggledAncModes ?? prev.holdBothToggledAncModes,
      autoPause: newSettings.autoPause ?? prev.autoPause,
      soundQuality: newSettings.soundQuality ?? prev.soundQuality,
    ));

    // Si la configuración incluye un cambio en el modo de calidad de sonido, aplicarlo
    if (newSettings.soundQuality != null &&
        newSettings.soundQuality != prev.soundQuality &&
        model.supportsSoundQuality) {
      await setSoundQualityMode(newSettings.soundQuality!);
    }
  }
}

/// Placeholder simulator for Huawei headphones
class HuaweiHeadphonesSimPlaceholder extends HuaweiHeadphonesBase
    with
        BluetoothHeadphonesSimPlaceholder,
        LRCBatteryAlwaysFullSimPlaceholder,
        AncSimPlaceholder,
        SoundQualitySimPlaceholder {
  final HuaweiModelDefinition model;

  const HuaweiHeadphonesSimPlaceholder(this.model);

  @override
  String get name => model.name;

  @override
  ValueStream<String> get imageAssetPath => BehaviorSubject.seeded(model.imageAssetPath);

  @override
  ValueStream<HuaweiHeadphonesSettings> get settings => BehaviorSubject();

  @override
  Future<void> setSettings(HuaweiHeadphonesSettings newSettings) async {}
}
