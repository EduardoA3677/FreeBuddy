import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:the_last_bluetooth/the_last_bluetooth.dart' as tlb;

import '../../logger.dart';
import '../framework/anc.dart';
import '../framework/bluetooth_headphones.dart';
import '../framework/headphones_info.dart';
import '../framework/headphones_settings.dart';
import '../framework/lrc_battery.dart';
import '../huawei/features/anc_impl.dart';
import '../huawei/features/auto_pause_impl.dart';
import '../huawei/features/battery_impl.dart';
import '../huawei/features/double_tap_impl.dart';
import '../huawei/features/hold_impl.dart';
import '../huawei/features/settings.dart';
import '../huawei/mbb.dart';

/// Abstract base class for Huawei headphones
abstract class HuaweiHeadphonesBase
    implements
        BluetoothHeadphones,
        HeadphonesModelInfo,
        LRCBattery,
        Anc,
        HeadphonesSettings<HuaweiHeadphonesSettings> {
  const HuaweiHeadphonesBase();

  @override
  String get vendor => "Huawei";
}

/// Definition for a Huawei headphones model with all its capabilities
class HuaweiModelDefinition {
  final String name;
  final RegExp idNameRegex;
  final String imageAssetPath;
  final bool supportsAnc;
  final bool supportsDoubleTap;
  final bool supportsHold;
  final bool supportsAutoPause;
  final HuaweiHeadphonesSettings defaultSettings;

  const HuaweiModelDefinition({
    required this.name,
    required this.idNameRegex,
    required this.imageAssetPath,
    this.supportsAnc = false,
    this.supportsDoubleTap = false,
    this.supportsHold = false,
    this.supportsAutoPause = false,
    required this.defaultSettings,
  });

  /// Creates an implementation instance for this model
  HuaweiHeadphonesImpl createImpl(
      StreamChannel<MbbCommand> mbb, tlb.BluetoothDevice device) {
    return HuaweiHeadphonesImpl(
      modelDefinition: this,
      mbb: mbb,
      bluetoothDevice: device,
    );
  }
}

/// Implementation of Huawei headphones that handles communication
/// with the device based on its model definition
class HuaweiHeadphonesImpl extends HuaweiHeadphonesBase {
  final HuaweiModelDefinition modelDefinition;
  final tlb.BluetoothDevice _bluetoothDevice;
  final StreamChannel<MbbCommand> _mbb;

  // Stream controllers
  final _bluetoothAliasCtrl = BehaviorSubject<String>();
  final _lrcBatteryCtrl = BehaviorSubject<LRCBatteryLevels>();
  final _ancModeCtrl = BehaviorSubject<AncMode>();
  final _settingsCtrl = BehaviorSubject<HuaweiHeadphonesSettings>();

  /// This watches if we are still missing any info and re-requests it
  late StreamSubscription _watchdogStreamSub;

  HuaweiHeadphonesImpl({
    required this.modelDefinition,
    required StreamChannel<MbbCommand> mbb,
    required tlb.BluetoothDevice bluetoothDevice,
  })  : _mbb = mbb,
        _bluetoothDevice = bluetoothDevice {
    _initializeHeadphones();
  }

  void _initializeHeadphones() {
    // Subscribe to device alias
    final aliasStreamSub = _bluetoothDevice.alias
        .listen((alias) => _bluetoothAliasCtrl.add(alias));
    _bluetoothAliasCtrl.onCancel = () => aliasStreamSub.cancel();

    // Initialize settings with default values
    _settingsCtrl.add(modelDefinition.defaultSettings);

    // Listen to MBB commands from device
    _mbb.stream.listen(
      (e) {
        try {
          _handleMbbCommand(e);
        } catch (e, s) {
          logg.e(e, stackTrace: s);
        }
      },
      onError: logg.onError,
      onDone: () {
        _watchdogStreamSub.cancel();
        _closeAllStreams();
      },
    );

    _requestInitialInfo();
    _startWatchdog();
  }

  void _closeAllStreams() {
    _bluetoothAliasCtrl.close();
    _lrcBatteryCtrl.close();
    _ancModeCtrl.close();
    _settingsCtrl.close();
  }

  void _requestInitialInfo() {
    // Request battery info
    _mbb.sink.add(BatteryImplementation.getBatteryCommand);

    // Request other features based on capabilities
    if (modelDefinition.supportsAnc) {
      _mbb.sink.add(AncImplementation.getAncCommand);
    }

    if (modelDefinition.supportsAutoPause) {
      _mbb.sink.add(AutoPauseImplementation.getAutoPauseCommand);
    }

    if (modelDefinition.supportsDoubleTap) {
      _mbb.sink.add(DoubleTapImplementation.getDoubleTapCommand);
    }

    if (modelDefinition.supportsHold) {
      _mbb.sink.add(HoldImplementation.getHoldCommand);
      _mbb.sink.add(HoldImplementation.getHoldToggledModesCommand);
    }
  }

  void _startWatchdog() {
    _watchdogStreamSub =
        Stream.periodic(const Duration(seconds: 3)).listen((_) {
      bool needsRefresh = false;

      // Check for missing battery info
      if (lrcBattery.valueOrNull == null) {
        needsRefresh = true;
      }

      // Check for missing ANC info if supported
      if (modelDefinition.supportsAnc && ancMode.valueOrNull == null) {
        needsRefresh = true;
      }

      // Check for missing settings
      if (settings.valueOrNull == null) {
        needsRefresh = true;
      }

      if (needsRefresh) {
        _requestInitialInfo();
      }
    });
  }

  void _handleMbbCommand(MbbCommand cmd) {
    // Handle battery information
    if (BatteryImplementation.handleBatteryUpdate(cmd, _lrcBatteryCtrl)) {
      return;
    }

    // Process ANC updates if supported
    if (modelDefinition.supportsAnc &&
        AncImplementation.handleAncUpdate(cmd, _ancModeCtrl)) {
      return;
    }

    // Handle settings updates
    final lastSettings =
        _settingsCtrl.valueOrNull ?? modelDefinition.defaultSettings;
    HuaweiHeadphonesSettings? updatedSettings;

    // Process double-tap settings if supported
    if (modelDefinition.supportsDoubleTap) {
      updatedSettings =
          DoubleTapImplementation.handleDoubleTapUpdate(cmd, lastSettings);
    }

    // Process hold settings if supported
    if (modelDefinition.supportsHold) {
      final holdSettings = HoldImplementation.handleHoldUpdate(
          cmd, updatedSettings ?? lastSettings);
      if (holdSettings != null) {
        updatedSettings = holdSettings;
      }

      final holdModesSettings = HoldImplementation.handleHoldToggledModesUpdate(
          cmd, updatedSettings ?? lastSettings);
      if (holdModesSettings != null) {
        updatedSettings = holdModesSettings;
      }
    }

    // Process auto-pause settings if supported
    if (modelDefinition.supportsAutoPause) {
      final autoPauseSettings = AutoPauseImplementation.handleAutoPauseUpdate(
          cmd, updatedSettings ?? lastSettings);
      if (autoPauseSettings != null) {
        updatedSettings = autoPauseSettings;
      }
    }

    // Update settings if any changes were detected
    if (updatedSettings != null) {
      _settingsCtrl.add(updatedSettings);
    }
  }

  // BluetoothHeadphones implementation
  @override
  ValueStream<int> get batteryLevel => _bluetoothDevice.battery;

  @override
  ValueStream<String> get bluetoothAlias => _bluetoothAliasCtrl.stream;

  @override
  String get bluetoothName => _bluetoothDevice.name.valueOrNull ?? "Unknown";

  @override
  String get macAddress => _bluetoothDevice.mac;

  // LRCBattery implementation
  @override
  ValueStream<LRCBatteryLevels> get lrcBattery => _lrcBatteryCtrl.stream;

  // HeadphonesModelInfo implementation
  @override
  String get name => modelDefinition.name;

  @override
  ValueStream<String> get imageAssetPath =>
      BehaviorSubject.seeded(modelDefinition.imageAssetPath);

  // Anc implementation
  @override
  ValueStream<AncMode> get ancMode => _ancModeCtrl.stream;

  @override
  Future<void> setAncMode(AncMode mode) async {
    if (modelDefinition.supportsAnc) {
      _mbb.sink.add(AncImplementation.setAncCommand(mode));
    }
  }

  // HeadphonesSettings implementation
  @override
  ValueStream<HuaweiHeadphonesSettings> get settings => _settingsCtrl.stream;

  @override
  Future<void> setSettings(HuaweiHeadphonesSettings newSettings) async {
    final prev = _settingsCtrl.valueOrNull ?? modelDefinition.defaultSettings;

    // Apply double-tap settings if supported
    if (modelDefinition.supportsDoubleTap) {
      DoubleTapImplementation.applyDoubleTapSettings(_mbb, prev, newSettings);
    }

    // Apply hold settings if supported
    if (modelDefinition.supportsHold) {
      HoldImplementation.applyHoldSettings(_mbb, prev, newSettings);
    }

    // Apply auto-pause settings if supported
    if (modelDefinition.supportsAutoPause) {
      AutoPauseImplementation.applyAutoPauseSettings(_mbb, prev, newSettings);
    }
  }
}
