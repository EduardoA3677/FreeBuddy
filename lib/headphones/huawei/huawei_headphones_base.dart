import '../framework/anc.dart';
import '../framework/bluetooth_headphones.dart';
import '../framework/headphones_info.dart';
import '../framework/headphones_settings.dart';
import '../framework/lrc_battery.dart';
import '../framework/sound_quality.dart';
import 'features/settings.dart';

/// Base abstract class for all Huawei headphones.
/// It defines the common interface that all Huawei headphones must implement.
abstract class HuaweiHeadphonesBase
    implements
        BluetoothHeadphones,
        HeadphonesModelInfo,
        LRCBattery,
        Anc,
        SoundQuality,
        HeadphonesSettings<HuaweiHeadphonesSettings> {
  const HuaweiHeadphonesBase();

  @override
  String get vendor => "Huawei";
}
