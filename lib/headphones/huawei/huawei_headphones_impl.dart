import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:the_last_bluetooth/the_last_bluetooth.dart' as tlb;

import '../../logger.dart';
import '../framework/anc.dart';
import '../framework/lrc_battery.dart';
import '../model_definition/huawei_models_definition.dart';
import 'features/anc_feature.dart' as anc;
import 'features/auto_pause_feature.dart' as auto_pause;
import 'features/base/feature_registry.dart';
import 'features/battery_feature.dart' as battery;
import 'features/double_tap_feature.dart' as double_tap;
import 'features/hold_feature.dart' as hold;
import 'features/settings.dart';
import 'huawei_headphones_base.dart';
import 'mbb.dart';

/// Enhanced implementation of Huawei headphones that uses a feature-based approach
class HuaweiHeadphonesImpl extends HuaweiHeadphonesBase {
  final HuaweiModelDefinition modelDefinition;
  final tlb.BluetoothDevice _bluetoothDevice;
  final StreamChannel<MbbCommand> _mbb;

  // Stream controllers
  final _bluetoothAliasCtrl = BehaviorSubject<String>();
  final _lrcBatteryCtrl = BehaviorSubject<LRCBatteryLevels>();
  final _ancModeCtrl = BehaviorSubject<AncMode>();
  final _settingsCtrl = BehaviorSubject<HuaweiHeadphonesSettings>();

  // Features
  late final FeatureRegistry _featureRegistry;
  battery.BatteryFeature? _batteryFeature;
  anc.AncFeature? _ancFeature;

  /// This watches if we are still missing any info and re-requests it
  late StreamSubscription _watchdogStreamSub;

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

    // Initialize feature registry
    _featureRegistry = FeatureRegistry(
      mbb: _mbb,
      supportCheck: _isFeatureSupported,
    );

    // Create and register features
    _registerFeatures();

    // Listen to MBB commands
    _mbb.stream.listen(
      _handleMbbCommand,
      onError: (error, stackTrace) => AppLogger.log(LogLevel.error, "MBB Stream Error",
          error: error, stackTrace: stackTrace),
      onDone: () {
        _watchdogStreamSub.cancel();
        _closeAllStreams();
      },
    );

    _startWatchdog();
  }

  bool _isFeatureSupported(String featureId) {
    return switch (featureId) {
      anc.AncFeature.featureId => modelDefinition.supportsAnc,
      double_tap.DoubleTapFeature.featureId =>
        modelDefinition.supportsDoubleTap,
      hold.HoldFeature.featureId => modelDefinition.supportsHold,
      auto_pause.AutoPauseFeature.featureId =>
        modelDefinition.supportsAutoPause,
      battery.BatteryFeature.featureId => true, // Battery is always supported
      _ => false,
    };
  }

  void _registerFeatures() {
    // Create battery feature
    _batteryFeature = battery.BatteryFeature();
    _featureRegistry.registerFeature(_batteryFeature!);

    // Link battery feature to LRC battery stream
    _batteryFeature!.batteryLevels.listen(_lrcBatteryCtrl.add);

    // Create ANC feature if supported
    if (modelDefinition.supportsAnc) {
      _ancFeature = anc.AncFeature();
      _featureRegistry.registerFeature(_ancFeature!);

      // Link ANC feature to ANC mode stream
      _ancFeature!.ancMode.listen(_ancModeCtrl.add);
    }

    // Register other features
    if (modelDefinition.supportsDoubleTap) {
      _featureRegistry.registerFeature(double_tap.DoubleTapFeature());
    }

    if (modelDefinition.supportsHold) {
      _featureRegistry.registerFeature(hold.HoldFeature());
    }

    if (modelDefinition.supportsAutoPause) {
      _featureRegistry.registerFeature(auto_pause.AutoPauseFeature());
    }
  }

  void _closeAllStreams() {
    _bluetoothAliasCtrl.close();
    _lrcBatteryCtrl.close();
    _ancModeCtrl.close();
    _settingsCtrl.close();

    _featureRegistry.dispose();
  }

  void _handleMbbCommand(MbbCommand cmd) {
    try {
      // Allow feature registry to handle the command
      _featureRegistry.handleMbbCommand(cmd);

      // Process settings updates
      final lastSettings =
          _settingsCtrl.valueOrNull ?? modelDefinition.defaultSettings;
      final updatedSettings =
          _featureRegistry.updateSettings(cmd, lastSettings);

      if (updatedSettings != null) {
        _settingsCtrl.add(updatedSettings);
      }
    } catch (e, s) {
      AppLogger.log(LogLevel.error, "Error handling MBB command",
          error: e, stackTrace: s);
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
        // Re-request data through features
        if (_batteryFeature != null) {
          _batteryFeature!.requestInitialData(_mbb);
        }

        if (_ancFeature != null) {
          _ancFeature!.requestInitialData(_mbb);
        }
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
    if (modelDefinition.supportsAnc && _ancFeature != null) {
      await _ancFeature!.setMode(mode, _mbb);
    }
  }

  // HeadphonesSettings implementation
  @override
  ValueStream<HuaweiHeadphonesSettings> get settings => _settingsCtrl.stream;

  @override
  Future<void> setSettings(HuaweiHeadphonesSettings newSettings) async {
    await _featureRegistry.applySettings(newSettings);
  }
}
