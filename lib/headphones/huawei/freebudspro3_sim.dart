import 'package:rxdart/rxdart.dart';

import '../framework/anc.dart';
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
      ldac: false,
      lowLatency: false
    ),
  );

  final _ldacEnabledCtrl = BehaviorSubject<bool>.seeded(false);
  final _lowLatencyEnabledCtrl = BehaviorSubject<bool>.seeded(false);

  @override
  ValueStream<HuaweiFreeBudsPro3Settings> get settings => _settingsCtrl.stream;

  @override
  Future<void> setSettings(HuaweiFreeBudsPro3Settings newSettings) async {
    _settingsCtrl.add(
      _settingsCtrl.value.copyWith(
        doubleTapLeft: newSettings.doubleTapLeft,
        doubleTapRight: newSettings.doubleTapRight,
        holdBoth: newSettings.holdBoth,
        holdBothToggledAncModes: newSettings.holdBothToggledAncModes,
        autoPause: newSettings.autoPause,
        ldac: newSettings.ldac,
        lowLatency: newSettings.lowLatency,
      ),
    );
    if (newSettings.ldac != null) {
        _ldacEnabledCtrl.add(newSettings.ldac!);
    }
      if (newSettings.lowLatency != null) {
        _lowLatencyEnabledCtrl.add(newSettings.lowLatency!);
      }
    }
  
    @override
    ValueStream<bool> get ldacEnabled => _ldacEnabledCtrl.stream;
  
    @override
    Future<void> setLdacEnabled(bool enabled) async {
      _ldacEnabledCtrl.add(enabled);
      _settingsCtrl.add(_settingsCtrl.value.copyWith(ldac: enabled));
    }
  
    @override
    ValueStream<bool> get lowLatencyEnabled => _lowLatencyEnabledCtrl.stream;
  
    @override
    Future<void> setLowLatencyEnabled(bool enabled) async {
      _lowLatencyEnabledCtrl.add(enabled);
      _settingsCtrl.add(_settingsCtrl.value.copyWith(lowLatency: enabled));
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
  Future<void> setLdacEnabled(bool enabled) async {}
  
  @override
  ValueStream<bool> get lowLatencyEnabled => BehaviorSubject();
  
  @override
  Future<void> setLowLatencyEnabled(bool enabled) async {}

  @override
  Future<void> setSettings(HuaweiFreeBudsPro3Settings newSettings) async {}
}
