import 'package:rxdart/rxdart.dart';

import '../framework/anc.dart';
import '../framework/ldac.dart';
import '../simulators/anc_sim.dart';
import '../simulators/bluetooth_headphones_sim.dart';
import '../simulators/lrc_battery_sim.dart';
import 'freebudspro3.dart';
import 'settings.dart';

final class HuaweiFreeBudsPro3Sim extends HuaweiFreeBudsPro3
    with BluetoothHeadphonesSim, LRCBatteryAlwaysFullSim, AncSim {
  // ehhhhhh...

  final _settingsCtrl = BehaviorSubject<HuaweiFreeBudsPro3Settings>.seeded(
    const HuaweiFreeBudsPro3Settings(
      doubleTapLeft: DoubleTap.playPause,
      doubleTapRight: DoubleTap.playPause,
      holdBoth: Hold.cycleAnc,
      holdBothToggledAncModes: {
        AncMode.noiseCancelling,
        AncMode.off,
        AncMode.transparency,
      },
      autoPause: true,
      ldac: true,
      lowLatency: true,
      ldacMode: LdacMode.quality,
    ),
  );
  
  final _ldacEnabledCtrl = BehaviorSubject<bool>.seeded(true);
  final _ldacModeCtrl = BehaviorSubject<LdacMode>.seeded(LdacMode.quality);

  @override
  ValueStream<HuaweiFreeBudsPro3Settings> get settings => _settingsCtrl.stream;

  @override
  ValueStream<bool> get ldacEnabled => _ldacEnabledCtrl.stream;
  
  @override
  ValueStream<LdacMode> get ldacMode => _ldacModeCtrl.stream;
  
  @override
  Future<void> setLdacEnabled(bool enabled) async {
    _ldacEnabledCtrl.add(enabled);
    _settingsCtrl.add(_settingsCtrl.value.copyWith(ldac: enabled));
  }
  
  @override
  Future<void> setLdacMode(LdacMode mode) async {
    _ldacModeCtrl.add(mode);
    _settingsCtrl.add(_settingsCtrl.value.copyWith(ldacMode: mode));
  }

  @override
  Future<void> setSettings(HuaweiFreeBudsPro3Settings newSettings) async {
    final settings = _settingsCtrl.value.copyWith(
      doubleTapLeft: newSettings.doubleTapLeft,
      doubleTapRight: newSettings.doubleTapRight,
      holdBoth: newSettings.holdBoth,
      holdBothToggledAncModes: newSettings.holdBothToggledAncModes,
      autoPause: newSettings.autoPause,
      ldac: newSettings.ldac,
      lowLatency: newSettings.lowLatency,
      ldacMode: newSettings.ldacMode,
    );
    
    _settingsCtrl.add(settings);
    
    if (newSettings.ldac != null) {
      _ldacEnabledCtrl.add(newSettings.ldac!);
    }
    
    if (newSettings.ldacMode != null) {
      _ldacModeCtrl.add(newSettings.ldacMode!);
    }
  }
}
// Classo use as placeholder for Disabled() widget
// this is not done with mixins because we may want to fill it with
// last-remembered values in future, and we will pretty much override
// all of this
//
// ...or not. I just don't know yet 🤷

final class HuaweiFreeBudsPro3SimPlaceholder extends HuaweiFreeBudsPro3
    with
        BluetoothHeadphonesSimPlaceholder,
        LRCBatteryAlwaysFullSimPlaceholder,
        AncSimPlaceholder {
  const HuaweiFreeBudsPro3SimPlaceholder();

  @override
  ValueStream<HuaweiFreeBudsPro3Settings> get settings => BehaviorSubject();
  
  @override
  ValueStream<bool> get ldacEnabled => BehaviorSubject();
  
  @override
  ValueStream<LdacMode> get ldacMode => BehaviorSubject();
  
  @override
  Future<void> setLdacEnabled(bool enabled) async {}
  
  @override
  Future<void> setLdacMode(LdacMode mode) async {}

  @override
  Future<void> setSettings(HuaweiFreeBudsPro3Settings newSettings) async {}
}
