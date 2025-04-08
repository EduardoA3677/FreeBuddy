import '../framework/anc.dart';
import '../framework/bluetooth_headphones.dart';
import '../framework/headphones_info.dart';
import '../framework/headphones_settings.dart';
import '../framework/lrc_battery.dart';
import 'features/settings.dart';

/// Base abstract class for all Huawei headphones.
/// It defines the common interface that all Huawei headphones must implement.
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
