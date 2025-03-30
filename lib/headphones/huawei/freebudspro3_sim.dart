import 'package:rxdart/rxdart.dart';

import '../framework/anc.dart';
import '../framework/dual_connect.dart';
import '../framework/ldac.dart';
import '../framework/low_latency.dart';
import '../framework/sound_quality.dart';
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
      lowLatency: false,
    ),
  );

  final _ldacEnabledCtrl = BehaviorSubject<bool>.seeded(false);
  final _lowLatencyEnabledCtrl = BehaviorSubject<bool>.seeded(false);
  final _dualConnectEnabledCtrl = BehaviorSubject<bool>.seeded(false);
  final _dualConnectDevicesCtrl = BehaviorSubject<Map<String, DualConnectDevice>>.seeded({});
  final _preferredDeviceMacCtrl = BehaviorSubject<String>.seeded("000000000000");
  final _soundQualityCtrl = BehaviorSubject<SoundQualityPreference>.seeded(SoundQualityPreference.quality);
  final _soundQualityOptionsCtrl = BehaviorSubject<List<SoundQualityPreference>>.seeded([
    SoundQualityPreference.connectivity, 
    SoundQualityPreference.quality
  ]);

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
  
  @override
  ValueStream<bool> get dualConnectEnabled => _dualConnectEnabledCtrl.stream;
  
  @override
  ValueStream<Map<String, DualConnectDevice>> get dualConnectDevices => 
      _dualConnectDevicesCtrl.stream;
  
  @override
  ValueStream<String> get preferredDeviceMac => _preferredDeviceMacCtrl.stream;
  
  @override
  Future<void> setDualConnectEnabled(bool enabled) async {
    _dualConnectEnabledCtrl.add(enabled);
  }
  
  @override
  Future<void> setPreferredDevice(String mac) async {
    _preferredDeviceMacCtrl.add(mac);
    final devices = _dualConnectDevicesCtrl.value;
    final updatedDevices = <String, DualConnectDevice>{};
    
    for (final entry in devices.entries) {
      final device = entry.value;
      updatedDevices[entry.key] = DualConnectDevice(
        name: device.name,
        mac: device.mac,
        preferred: device.mac == mac,
        connected: device.connected,
        playing: device.playing,
        autoConnect: device.autoConnect,
      );
    }
    
    _dualConnectDevicesCtrl.add(updatedDevices);
  }
  
  @override
  Future<void> executeDualConnCommand(String mac, DualConnCommand command) async {
    final devices = _dualConnectDevicesCtrl.value;
    if (!devices.containsKey(mac)) return;
    
    final device = devices[mac]!;
    final updated = <String, DualConnectDevice>{};
    
    for (final entry in devices.entries) {
      if (entry.key != mac) {
        updated[entry.key] = entry.value;
        continue;
      }
      
      updated[mac] = DualConnectDevice(
        name: device.name,
        mac: device.mac,
        preferred: device.preferred,
        connected: command == DualConnCommand.connect ? true : 
                  command == DualConnCommand.disconnect ? false : device.connected,
        playing: command == DualConnCommand.connect ? true : 
                command == DualConnCommand.disconnect ? false : device.playing,
        autoConnect: command == DualConnCommand.enableAuto ? true : 
                    command == DualConnCommand.disableAuto ? false : device.autoConnect,
      );
    }
    
    _dualConnectDevicesCtrl.add(updated);
  }
  
  @override
  Future<void> refreshDeviceList() async {
    // Simulation doesn't need to do anything for refresh
  }

  @override
  ValueStream<SoundQualityPreference> get soundQuality => _soundQualityCtrl.stream;
  
  @override
  ValueStream<List<SoundQualityPreference>> get soundQualityOptions => _soundQualityOptionsCtrl.stream;
  
  @override
  Future<void> setSoundQuality(SoundQualityPreference quality) async {
    _soundQualityCtrl.add(quality);
  }
}

/// Class to use as placeholder for Disabled() widget
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
  Future<void> setSettings(HuaweiFreeBudsPro3Settings newSettings) async {}
  
  @override
  ValueStream<bool> get ldacEnabled => BehaviorSubject();
  
  @override
  Future<void> setLdacEnabled(bool enabled) async {}
  
  @override
  ValueStream<bool> get lowLatencyEnabled => BehaviorSubject();
  
  @override
  Future<void> setLowLatencyEnabled(bool enabled) async {}
  
  @override
  ValueStream<bool> get dualConnectEnabled => BehaviorSubject();
  
  @override
  ValueStream<Map<String, DualConnectDevice>> get dualConnectDevices => BehaviorSubject();
  
  @override
  ValueStream<String> get preferredDeviceMac => BehaviorSubject();
  
  @override
  Future<void> setDualConnectEnabled(bool enabled) async {}
  
  @override
  Future<void> setPreferredDevice(String mac) async {}
  
  @override
  Future<void> executeDualConnCommand(String mac, DualConnCommand command) async {}
  
  @override
  Future<void> refreshDeviceList() async {}
  
  @override
  ValueStream<SoundQualityPreference> get soundQuality => BehaviorSubject();
  
  @override
  ValueStream<List<SoundQualityPreference>> get soundQualityOptions => BehaviorSubject();
  
  @override
  Future<void> setSoundQuality(SoundQualityPreference quality) async {}
}
