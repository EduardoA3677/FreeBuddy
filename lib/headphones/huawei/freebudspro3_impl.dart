import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:the_last_bluetooth/the_last_bluetooth.dart' as tlb;

import '../../logger.dart';
import '../framework/anc.dart';
import '../framework/dual_connect.dart';
import '../framework/low_latency.dart';
import '../framework/lrc_battery.dart';
import '../framework/sound_quality.dart';
import 'freebudspro3.dart';
import 'mbb.dart';
import 'settings.dart';

extension HexEncoder on List<int> {
  String get hex => map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

final class HuaweiFreeBudsPro3Impl extends HuaweiFreeBudsPro3 {
  final tlb.BluetoothDevice _bluetoothDevice;

  /// Bluetooth serial port that we communicate over
  final StreamChannel<MbbCommand> _mbb;

  // * stream controllers
  final _batteryLevelCtrl = BehaviorSubject<int>();
  final _bluetoothAliasCtrl = BehaviorSubject<String>();
  final _bluetoothNameCtrl = BehaviorSubject<String>();
  final _lrcBatteryCtrl = BehaviorSubject<LRCBatteryLevels>();
  final _ancModeCtrl = BehaviorSubject<AncMode>();
  final _settingsCtrl = BehaviorSubject<HuaweiFreeBudsPro3Settings>();
  final _lowLatencyEnabledCtrl = BehaviorSubject<bool>();
  final _dualConnectEnabledCtrl = BehaviorSubject<bool>();
  final _dualConnectDevicesCtrl = BehaviorSubject<Map<String, DualConnectDevice>>();
  final _preferredDeviceMacCtrl = BehaviorSubject<String>();
  final _soundQualityCtrl = BehaviorSubject<SoundQualityPreference>();
  final _soundQualityOptionsCtrl = BehaviorSubject<List<SoundQualityPreference>>.seeded([
    SoundQualityPreference.connectivity, 
    SoundQualityPreference.quality
  ]);
  // stream controllers *

  /// This watches if we are still missing any info and re-requests it
  late StreamSubscription _watchdogStreamSub;
  
  // DualConnect related fields
  final Map<int, DualConnectDevice> _pendingDevices = {};
  int _devicesCount = 999;
  
  HuaweiFreeBudsPro3Impl(this._mbb, this._bluetoothDevice) {
    // hope this will nicely play with closing, idk honestly
    final aliasStreamSub = _bluetoothDevice.alias
        .listen((alias) => _bluetoothAliasCtrl.add(alias));
    _bluetoothAliasCtrl.onCancel = () => aliasStreamSub.cancel();

    _mbb.stream.listen(
      (e) {
        try {
          _evalMbbCommand(e);
        } catch (e, s) {
          logg.e(e, stackTrace: s);
        }
      },
      onError: logg.onError,
      onDone: () {
        _watchdogStreamSub.cancel();

        // close all streams
        _batteryLevelCtrl.close();
        _bluetoothAliasCtrl.close();
        _bluetoothNameCtrl.close();
        _lrcBatteryCtrl.close();
        _ancModeCtrl.close();
        _settingsCtrl.close();
        _lowLatencyEnabledCtrl.close();
        _dualConnectEnabledCtrl.close();
        _dualConnectDevicesCtrl.close();
        _preferredDeviceMacCtrl.close();
        _soundQualityCtrl.close();
        _soundQualityOptionsCtrl.close();
      },
    );
    _initRequestInfo();
    _watchdogStreamSub =
        Stream.periodic(const Duration(seconds: 3)).listen((_) {
      if ([
        batteryLevel.valueOrNull,
        // no alias because it's okay to be null 👍
        lrcBattery.valueOrNull,
        ancMode.valueOrNull,
        settings.valueOrNull,
        lowLatencyEnabled.valueOrNull,
        soundQuality.valueOrNull,
      ].any((e) => e == null)) {
        _initRequestInfo();
      }
    });
  }

  void _evalMbbCommand(MbbCommand cmd) {
    final lastSettings =
        _settingsCtrl.valueOrNull ?? const HuaweiFreeBudsPro3Settings();
    switch (cmd.args) {
      // # AncMode
      case {1: [_, var ancModeCode, ...]} when cmd.isAbout(_Cmd.getAnc):
        final mode =
            AncMode.values.firstWhereOrNull((e) => e.mbbCode == ancModeCode);
        if (mode != null) _ancModeCtrl.add(mode);
        break;
      // # BatteryLevels
      case {2: var level, 3: var status}
          when cmd.serviceId == 1 &&
              (cmd.commandId == 39 || cmd.commandId == 8):
        _lrcBatteryCtrl.add(LRCBatteryLevels(
          level[0] == 0 ? null : level[0],
          level[1] == 0 ? null : level[1],
          level[2] == 0 ? null : level[2],
          status[0] == 1,
          status[1] == 1,
          status[2] == 1,
        ));
        break;
      // # Settings(autoPause)
      case {1: [var autoPauseCode, ...]} when cmd.isAbout(_Cmd.getAutoPause):
        _settingsCtrl.add(lastSettings.copyWith(autoPause: autoPauseCode == 1));
        break;
      // # Settings(soundQuality/ldac)
      case {1: [var soundQualityCode, ...]} when cmd.isAbout(_Cmd.getSoundQuality):
        final isEnabled = soundQualityCode == 1;
        _settingsCtrl.add(lastSettings.copyWith(ldac: isEnabled));
        break;
      // # Settings(soundQualityPreference)  
      case {2: [var qualityCode, ...]} when cmd.isAbout(_Cmd.getSoundQualityPreference):
        _soundQualityCtrl.add(qualityCode == 0 
          ? SoundQualityPreference.connectivity 
          : SoundQualityPreference.quality);
        break;
      // # Settings(lowLatency)
      case {1: [var lowLatencyCode, ...]} when cmd.isAbout(_Cmd.getLowLatency):
        final isEnabled = lowLatencyCode == 1;
        _settingsCtrl.add(lastSettings.copyWith(lowLatency: isEnabled));
        _lowLatencyEnabledCtrl.add(isEnabled);
        break;
      // # Settings(gestureDoubleTap)
      case {1: [var leftCode, ...], 2: [var rightCode, ...]}
          when cmd.isAbout(_Cmd.getGestureDoubleTap):
        _settingsCtrl.add(
          lastSettings.copyWith(
            doubleTapLeft:
                DoubleTap.values.firstWhereOrNull((e) => e.mbbCode == leftCode),
            doubleTapRight: DoubleTap.values
                .firstWhereOrNull((e) => e.mbbCode == rightCode),
          ),
        );
        break;
      // # Settings(hold)
      case {1: [var holdCode, ...]} when cmd.isAbout(_Cmd.getGestureHold):
        _settingsCtrl.add(
          lastSettings.copyWith(
            holdBoth:
                Hold.values.firstWhereOrNull((e) => e.mbbCode == holdCode),
          ),
        );
        break;
      // # Settings(holdModes)
      case {1: [var modesCode, ...]}
          when cmd.isAbout(_Cmd.getGestureHoldToggledAncModes):
        _settingsCtrl.add(
          lastSettings.copyWith(
            holdBothToggledAncModes:
                _Cmd.gestureHoldToggledAncModesFromMbbValue(modesCode),
          ),
        );
        break;
      // # DualConnect(enabled)
      case {1: [var enabledCode, ...]} when cmd.isAbout(_Cmd.getDualConnectEnabled):
        _dualConnectEnabledCtrl.add(enabledCode == 1);
        break;
      // # DualConnect(device)
      case {4: var macBytes} when cmd.isAbout(_Cmd.getDualConnectEnumerate):
        _handleDualConnectDevice(cmd);
        break;
    }
  }

  void _handleDualConnectDevice(MbbCommand cmd) {
    try {
      final macAddress = cmd.args[4]!.hex;
      if (macAddress.length < 12) return;
      
      final deviceIndex = int.parse(cmd.args[3]![0].toString());
      _devicesCount = int.parse(cmd.args[2]![0].toString());
      
      final name = utf8.decode(cmd.args[9] ?? [], allowMalformed: true);
      final autoConnect = (cmd.args[8]?[0] == 1);
      final preferred = (cmd.args[7]?[0] == 1);
      final connState = cmd.args[5]?[0] ?? 0;
      final connected = connState > 0;
      final playing = connState == 9;
      
      _pendingDevices[deviceIndex] = DualConnectDevice(
        name: name,
        mac: macAddress,
        preferred: preferred,
        connected: connected,
        playing: playing,
        autoConnect: autoConnect,
      );
      
      if (preferred) {
        _preferredDeviceMacCtrl.add(macAddress);
      }
      
      // Process if we have all devices or timeout
      if (_devicesCount == _pendingDevices.length) {
        _processPendingDevices();
      }
    } catch (e, s) {
      logg.e('Error handling DualConnect device', e, s);
    }
  }
  
  void _processPendingDevices() {
    final devices = <String, DualConnectDevice>{};
    for (final device in _pendingDevices.values) {
      devices[device.mac] = device;
    }
    _dualConnectDevicesCtrl.add(devices);
    _pendingDevices.clear();
  }

  Future<void> _initRequestInfo() async {
    _mbb.sink.add(_Cmd.getBattery);
    _mbb.sink.add(_Cmd.getAnc);
    _mbb.sink.add(_Cmd.getAutoPause);
    _mbb.sink.add(_Cmd.getSoundQuality);
    _mbb.sink.add(_Cmd.getLowLatency);
    _mbb.sink.add(_Cmd.getGestureDoubleTap);
    _mbb.sink.add(_Cmd.getGestureHold);
    _mbb.sink.add(_Cmd.getGestureHoldToggledAncModes);
    _mbb.sink.add(_Cmd.getSoundQualityPreference);
    _mbb.sink.add(_Cmd.getDualConnectEnabled);
    // Request device enumeration for DualConnect
    _mbb.sink.add(_Cmd.getDualConnectEnumerate);
  }

  @override
  ValueStream<int> get batteryLevel => _bluetoothDevice.battery;

  // i could pass btDevice.alias directly here, but Headphones take care
  // of closing everything
  @override
  ValueStream<String> get bluetoothAlias => _bluetoothAliasCtrl.stream;

  // huh, my past self thought that names will not change... and my future
  // (implementing TLB) thought otherwise 🤷🤷
  @override
  String get bluetoothName => _bluetoothDevice.name.valueOrNull ?? "Unknown";

  @override
  String get macAddress => _bluetoothDevice.mac;

  @override
  ValueStream<LRCBatteryLevels> get lrcBattery => _lrcBatteryCtrl.stream;

  @override
  ValueStream<AncMode> get ancMode => _ancModeCtrl.stream;

  @override
  Future<void> setAncMode(AncMode mode) async => _mbb.sink.add(_Cmd.anc(mode));

  @override
  ValueStream<HuaweiFreeBudsPro3Settings> get settings => _settingsCtrl.stream;

  @override
  ValueStream<bool> get ldacEnabled => soundQuality.map((q) => q == SoundQualityPreference.quality);
  
  @override
  Future<void> setLdacEnabled(bool enabled) async {
    await setSoundQuality(enabled ? SoundQualityPreference.quality : SoundQualityPreference.connectivity);
  }
  
  @override
  ValueStream<bool> get lowLatencyEnabled => _lowLatencyEnabledCtrl.stream;
  
  @override
  Future<void> setLowLatencyEnabled(bool enabled) async {
    _mbb.sink.add(_Cmd.lowLatency(enabled));
    _mbb.sink.add(_Cmd.getLowLatency);
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
    _mbb.sink.add(_Cmd.dualConnectToggle(enabled));
    _mbb.sink.add(_Cmd.getDualConnectEnabled);
  }
  
  @override
  Future<void> setPreferredDevice(String mac) async {
    _mbb.sink.add(_Cmd.dualConnectPreferred(mac));
    await refreshDeviceList();
  }
  
  @override
  Future<void> executeDualConnCommand(String mac, DualConnCommand command) async {
    _mbb.sink.add(_Cmd.dualConnectCommand(command, mac));
    await refreshDeviceList();
  }
  
  @override
  Future<void> refreshDeviceList() async {
    _pendingDevices.clear();
    _devicesCount = 999;
    _mbb.sink.add(_Cmd.getDualConnectEnabled);
    _mbb.sink.add(_Cmd.getDualConnectEnumerate);
  }
  
  @override
  ValueStream<SoundQualityPreference> get soundQuality => _soundQualityCtrl.stream;
  
  @override
  ValueStream<List<SoundQualityPreference>> get soundQualityOptions => _soundQualityOptionsCtrl.stream;
  
  @override
  Future<void> setSoundQuality(SoundQualityPreference quality) async {
    final value = quality == SoundQualityPreference.connectivity ? 0 : 1;
    _mbb.sink.add(_Cmd.setSoundQualityPreference(value));
    _mbb.sink.add(_Cmd.getSoundQualityPreference);
  }

  @override
  Future<void> setSettings(newSettings) async {
    final prev =
        _settingsCtrl.valueOrNull ?? const HuaweiFreeBudsPro3Settings();
    // this is VERY much a boilerplate
    // ...and, bloat...
    // and i don't think there is a need to export it somewhere else 🤷,
    // or make some other abstraction for it - maybe some day
    if ((newSettings.doubleTapLeft ?? prev.doubleTapLeft) !=
        prev.doubleTapLeft) {
      _mbb.sink.add(_Cmd.gestureDoubleTap(left: newSettings.doubleTapLeft!));
      _mbb.sink.add(_Cmd.getGestureDoubleTap);
    }
    if ((newSettings.doubleTapRight ?? prev.doubleTapRight) !=
        prev.doubleTapRight) {
      _mbb.sink.add(_Cmd.gestureDoubleTap(right: newSettings.doubleTapRight!));
      _mbb.sink.add(_Cmd.getGestureDoubleTap);
    }
    if ((newSettings.holdBoth ?? prev.holdBoth) != prev.holdBoth) {
      _mbb.sink.add(_Cmd.gestureHold(newSettings.holdBoth!));
      _mbb.sink.add(_Cmd.getGestureHold);
      _mbb.sink.add(_Cmd.getGestureHoldToggledAncModes);
    }
    if ((newSettings.holdBothToggledAncModes ?? prev.holdBothToggledAncModes) !=
        prev.holdBothToggledAncModes) {
      _mbb.sink.add(_Cmd.gestureHoldToggledAncModes(
          newSettings.holdBothToggledAncModes!));
      _mbb.sink.add(_Cmd.getGestureHold);
      _mbb.sink.add(_Cmd.getGestureHoldToggledAncModes);
    }
    if ((newSettings.autoPause ?? prev.autoPause) != prev.autoPause) {
      _mbb.sink.add(_Cmd.autoPause(newSettings.autoPause!));
      _mbb.sink.add(_Cmd.getAutoPause);
    }
    if ((newSettings.ldac ?? prev.ldac) != prev.ldac) {
      await setLdacEnabled(newSettings.ldac!);
    }
    if ((newSettings.lowLatency ?? prev.lowLatency) != prev.lowLatency) {
      _mbb.sink.add(_Cmd.lowLatency(newSettings.lowLatency!));
      _mbb.sink.add(_Cmd.getLowLatency);
    }
  }
}

/// This is just a holder for magic numbers
/// This isn't very pretty, or eliminates all of the boilerplate... but i
/// feel like nothing will so let's love it as it is <3
///
/// All elements names plainly like "noiseCancel" or "and" mean "set..X",
/// and getters actually have "get" in their names
abstract class _Cmd {
  static const getBattery = MbbCommand(1, 8);

  static const getAnc = MbbCommand(43, 42);

  static MbbCommand anc(AncMode mode) => MbbCommand(43, 4, {
        1: [mode.mbbCode, mode == AncMode.off ? 0 : 255]
      });

  static const getGestureDoubleTap = MbbCommand(1, 32);

  static MbbCommand gestureDoubleTap({DoubleTap? left, DoubleTap? right}) =>
      MbbCommand(1, 31, {
        if (left != null) 1: [left.mbbCode],
        if (right != null) 2: [right.mbbCode],
      });

  static const getGestureHold = MbbCommand(43, 23);

  static MbbCommand gestureHold(Hold gestureHold) => MbbCommand(43, 22, {
        1: [gestureHold.mbbCode]
      });

  static const getGestureHoldToggledAncModes = MbbCommand(43, 25);

  static Set<AncMode>? gestureHoldToggledAncModesFromMbbValue(int mbbValue) {
    return switch (mbbValue) {
      1 => const {AncMode.off, AncMode.noiseCancelling},
      2 => AncMode.values.toSet(),
      3 => const {AncMode.noiseCancelling, AncMode.transparency},
      4 => const {AncMode.off, AncMode.transparency},
      _ => null,
    };
  }

  static MbbCommand gestureHoldToggledAncModes(Set<AncMode> toggledModes) {
    int? mbbValue;
    const se = SetEquality();
    // can't really do that with pattern matching because it's a Set
    if (se.equals(toggledModes, {AncMode.off, AncMode.noiseCancelling})) {
      mbbValue = 1;
    }
    if (toggledModes.length == 3) mbbValue = 2;
    if (se.equals(
        toggledModes, {AncMode.noiseCancelling, AncMode.transparency})) {
      mbbValue = 3;
    }
    if (se.equals(toggledModes, {AncMode.off, AncMode.transparency})) {
      mbbValue = 4;
    }
    if (mbbValue == null) {
      logg.w("Unknown mbbValue for $toggledModes"
          " - setting as 2 for 'all of them' as a recovery");
      mbbValue = 2;
    }
    return MbbCommand(43, 24, {
      1: [mbbValue],
      2: [mbbValue]
    });
  }

  static const getAutoPause = MbbCommand(43, 17);

  static MbbCommand autoPause(bool enabled) => MbbCommand(43, 16, {
        1: [enabled ? 1 : 0]
      });

  static const getSoundQuality = MbbCommand(43, 19);
  
  static MbbCommand soundQuality(bool enabled) => MbbCommand(43, 18, {
        1: [enabled ? 1 : 0]
      });

  static const getLowLatency = MbbCommand(43, 21);
  
  static MbbCommand lowLatency(bool enabled) => MbbCommand(43, 20, {
        1: [enabled ? 1 : 0]
      });

  static const getDualConnectEnabled = MbbCommand(43, 44);
  
  static MbbCommand dualConnectToggle(bool enabled) => MbbCommand(43, 43, {
        1: [enabled ? 1 : 0]
      });

  static const getDualConnectEnumerate = MbbCommand(43, 45);

  static MbbCommand dualConnectPreferred(String mac) => MbbCommand(43, 46, {
        1: _hexToBytes(mac)
      });

  static MbbCommand dualConnectCommand(DualConnCommand command, String mac) =>
      MbbCommand(43, 47, {
        command.mbbCode: _hexToBytes(mac)
      });

  static const getSoundQualityPreference = MbbCommand(43, 165);

  static MbbCommand setSoundQualityPreference(int value) => MbbCommand(43, 164, {
        1: [value]
      });
      
  static List<int> _hexToBytes(String hex) {
    List<int> bytes = [];
    for (int i = 0; i < hex.length; i += 2) {
      if (i + 2 <= hex.length) {
        bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
      }
    }
    return bytes;
  }
}

extension _FBPro3AncMode on AncMode {
  int get mbbCode => switch (this) {
        AncMode.noiseCancelling => 1,
        AncMode.off => 0,
        AncMode.transparency => 2,
      };
}

extension _FBPro3DoubleTap on DoubleTap {
  int get mbbCode => switch (this) {
        DoubleTap.nothing => 255,
        DoubleTap.voiceAssistant => 0,
        DoubleTap.playPause => 1,
        DoubleTap.next => 2,
        DoubleTap.previous => 7
      };
}

extension _FBPro3Hold on Hold {
  int get mbbCode => switch (this) {
        Hold.nothing => 255,
        Hold.cycleAnc => 10,
      };
}
