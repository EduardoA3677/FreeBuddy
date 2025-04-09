import 'package:stream_channel/stream_channel.dart';
import 'package:the_last_bluetooth/the_last_bluetooth.dart' as tlb;

import '../model_definition/huawei_models_definition.dart';
import 'features/anc_feature.dart' as anc;
import 'features/auto_pause_feature.dart' as auto_pause;
import 'features/base/feature_registry.dart';
import 'features/battery_feature.dart' as battery;
import 'features/double_tap_feature.dart' as double_tap;
import 'features/hold_feature.dart' as hold;
import 'huawei_headphones_impl.dart';
import 'mbb.dart';

/// Factory class for creating Huawei headphones implementations
class HuaweiHeadphonesFactory {
  /// Create a new implementation of Huawei headphones
  static HuaweiHeadphonesImpl createImplementation({
    required HuaweiModelDefinition modelDefinition,
    required tlb.BluetoothDevice bluetoothDevice,
    required StreamChannel<MbbCommand> mbb,
  }) {
    return HuaweiHeadphonesImpl(
      modelDefinition: modelDefinition,
      bluetoothDevice: bluetoothDevice,
      mbb: mbb,
    );
  }

  /// Register all available features
  static void registerAllFeatures(FeatureRegistry registry) {
    registry.registerFeatures([
      battery.BatteryFeature(),
      anc.AncFeature(),
      double_tap.DoubleTapFeature(),
      hold.HoldFeature(),
      auto_pause.AutoPauseFeature(),
    ]);
  }
}
