import 'dart:typed_data';

import 'package:stream_channel/stream_channel.dart';
import 'package:the_last_bluetooth/the_last_bluetooth.dart';

import '../framework/bluetooth_headphones.dart';
import '../huawei/huawei_headphones_impl.dart';
import '../huawei/huawei_headphones_sim.dart';
import '../huawei/mbb.dart';
import '../model_definition/huawei_models_definition.dart';

typedef HeadphonesBuilder = BluetoothHeadphones Function(
    StreamChannel<Uint8List> io, BluetoothDevice device);

typedef MatchedModel = ({HeadphonesBuilder builder, BluetoothHeadphones placeholder});

MatchedModel? matchModel(BluetoothDevice matchedDevice) {
  final name = matchedDevice.name.value;

  // Try to match with Huawei models
  for (final model in HuaweiModels.allModels) {
    if (model.idNameRegex.hasMatch(name)) {
      return (
        builder: (io, dev) => HuaweiHeadphonesImpl(
              modelDefinition: model,
              bluetoothDevice: dev,
              mbb: mbbChannel(io),
            ),
        placeholder: HuaweiHeadphonesSimPlaceholder(model),
      ) as MatchedModel;
    }
  }

  // No match found
  return null;
}
