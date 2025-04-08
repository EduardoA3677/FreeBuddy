import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:the_last_bluetooth/the_last_bluetooth.dart' as tlb;

import '../../logger.dart';
import '../framework/anc.dart';
import '../framework/lrc_battery.dart';
import 'features/anc_feature.dart';
import 'features/auto_pause_feature.dart';
import 'features/battery_feature.dart';
import 'features/double_tap_feature.dart';
import 'features/hold_feature.dart';
import 'features/settings.dart';
import 'huawei_headphones_base.dart';
import 'mbb.dart';
import '../model_definition/huawei_models_definition.dart';

/// Implementation of Huawei headphones based on model definition
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

  /// Factory constructor that creates the appropriate implementation based on device name
  factory HuaweiHeadphonesImpl.fromDevice({
    required tlb.BluetoothDevice bluetoothDevice,
    required StreamChannel<MbbCommand> mbb,
  }) {
    final deviceName = bluetoothDevice.name.valueOrNull ?? "";
    try {
      final modelDef = HuaweiModels.findModelByName(deviceName);
      return HuaweiHeadphonesImpl(
        modelDefinition: modelDef,
        bluetoothDevice: bluetoothDevice,
        mbb: mbb,
      );
    } catch (e) {
      // Fallback to a default model if the device is not recognized
      logg.w(
          "Unsupported model: $deviceName. Using FreeBuds Pro 3 as fallback");
      return HuaweiHeadphonesImpl(
        modelDefinition: HuaweiModels.freeBudsPro3,
        bluetoothDevice: bluetoothDevice,
        mbb: mbb,
      );
    }
  }

  HuaweiHeadphonesImpl({
    required this.modelDefinition,
    required tlb.BluetoothDevice bluetoothDevice,
    required StreamChannel<MbbCommand> mbb,
  })  : _bluetoothDevice = bluetoothDevice,
        _mbb = mbb {
    _initialize();
  }

  void _initialize() {
    // Set up alias stream
    final aliasStreamSub = _bluetoothDevice.alias
        .listen((alias) => _bluetoothAliasCtrl.add(alias));
    _bluetoothAliasCtrl.onCancel = () => aliasStreamSub.cancel();

    // Initialize settings with default values
    _settingsCtrl.add(modelDefinition.defaultSettings);

    // Listen to MBB commands
    _mbb.stream.listen(
      _handleMbbCommand,
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

  void _handleMbbCommand(MbbCommand cmd) {
    try {
      // Handle battery updates
      if (BatteryFeature.handleBatteryUpdate(cmd, _lrcBatteryCtrl)) {
        return;
      }

      // Handle ANC updates if supported
      if (modelDefinition.supportsAnc &&
          AncFeature.handleAncUpdate(cmd, _ancModeCtrl)) {
        return;
      }

      // Handle settings updates
      final lastSettings =
          _settingsCtrl.valueOrNull ?? modelDefinition.defaultSettings;
      HuaweiHeadphonesSettings? updatedSettings;

      // Process double-tap settings
      if (modelDefinition.supportsDoubleTap) {
        final tapSettings =
            DoubleTapFeature.handleDoubleTapUpdate(cmd, lastSettings);
        if (tapSettings != null) {
          updatedSettings = tapSettings;
        }
      }

      // Process hold settings
      if (modelDefinition.supportsHold) {
        final holdSettings =
            HoldFeature.handleHoldUpdate(cmd, updatedSettings ?? lastSettings);
        if (holdSettings != null) {
          updatedSettings = holdSettings;
        }

        final modesSettings = HoldFeature.handleHoldToggledModesUpdate(
            cmd, updatedSettings ?? lastSettings);
        if (modesSettings != null) {
          updatedSettings = modesSettings;
        }
      }

      // Process auto-pause settings
      if (modelDefinition.supportsAutoPause) {
        final pauseSettings = AutoPauseFeature.handleAutoPauseUpdate(
            cmd, updatedSettings ?? lastSettings);
        if (pauseSettings != null) {
          updatedSettings = pauseSettings;
        }
      }

      // Update settings if any changes were detected
      if (updatedSettings != null) {
        _settingsCtrl.add(updatedSettings);
      }
    } catch (e, s) {
      logg.e("Error handling MBB command", error: e, stackTrace: s);
    }
  }

  void _requestInitialInfo() {
    // Always request battery info
    _mbb.sink.add(BatteryFeature.getBatteryCommand);

    // Request other features based on model capabilities
    if (modelDefinition.supportsAnc) {
      _mbb.sink.add(AncFeature.getAncCommand);
    }

    if (modelDefinition.supportsDoubleTap) {
      _mbb.sink.add(DoubleTapFeature.getDoubleTapCommand);
    }

    if (modelDefinition.supportsHold) {
      _mbb.sink.add(HoldFeature.getHoldCommand);
      _mbb.sink.add(HoldFeature.getHoldToggledModesCommand);
    }

    if (modelDefinition.supportsAutoPause) {
      _mbb.sink.add(AutoPauseFeature.getAutoPauseCommand);
    }
  }

  void _startWatchdog() {
    _watchdogStreamSub =
        Stream.periodic(const Duration(seconds: 3)).listen((_) {
      if ([
        batteryLevel.valueOrNull,
        lrcBattery.valueOrNull,
        if (modelDefinition.supportsAnc) ancMode.valueOrNull,
        settings.valueOrNull,
      ].any((e) => e == null)) {
        _requestInitialInfo();
      }
    });
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

  // HeadphonesModelInfo implementation
  @override
  String get name => modelDefinition.name;

  @override
  ValueStream<String> get imageAssetPath =>
      BehaviorSubject.seeded(modelDefinition.imageAssetPath);

  // LRCBattery implementation
  @override
  ValueStream<LRCBatteryLevels> get lrcBattery => _lrcBatteryCtrl.stream;

  // Anc implementation
  @override
  ValueStream<AncMode> get ancMode => _ancModeCtrl.stream;

  @override
  Future<void> setAncMode(AncMode mode) async {
    if (modelDefinition.supportsAnc) {
      _mbb.sink.add(AncFeature.setAncCommand(mode));
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
      DoubleTapFeature.applyDoubleTapSettings(_mbb, prev, newSettings);
    }

    // Apply hold settings if supported
    if (modelDefinition.supportsHold) {
      HoldFeature.applyHoldSettings(_mbb, prev, newSettings);
    }

    // Apply auto-pause settings if supported
    if (modelDefinition.supportsAutoPause && newSettings.autoPause != null) {
      AutoPauseFeature.applyAutoPauseSettings(_mbb, prev, newSettings);
    }
  }
}
