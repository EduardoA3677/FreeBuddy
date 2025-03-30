import 'package:rxdart/rxdart.dart';

import '../framework/anc.dart';
import '../framework/bluetooth_headphones.dart';
import '../framework/dual_connect.dart';
import '../framework/headphones_info.dart';
import '../framework/headphones_settings.dart';
import '../framework/low_latency.dart';
import '../framework/lrc_battery.dart';
import '../framework/sound_quality.dart';
import 'settings.dart';

/// Base abstract class of Pro 3's. It contains static info like vendor names etc,
/// but no logic whatsoever.
///
/// It makes both a solid ground for actual implementation (by defining what
/// features they implement), and some basic info for easy simulation
abstract base class HuaweiFreeBudsPro3
    implements
        BluetoothHeadphones,
        HeadphonesModelInfo,
        LRCBattery,
        Anc,
        HeadphonesSettings<HuaweiFreeBudsPro3Settings>,
        LowLatency,
        DualConnect,
        SoundQuality {
  const HuaweiFreeBudsPro3();

  @override
  String get vendor => "Huawei";

  @override
  String get name => "FreeBuds Pro 3";

  // NOTE/WARNING: Again as in HeadphonesModelInfo - i'm not sure if it's safe
  // to just leave it like that, but I will 🥰🥰
  @override
  ValueStream<String> get imageAssetPath =>
      BehaviorSubject.seeded('assets/app_icons/ic_launcher.png');

  // As I said everywhere else - i have no good idea where to put this stuff :/
  // This will be a bit of chaos for now 👍👍
  static final idNameRegex =
      RegExp(r'^(?=(HUAWEI FreeBuds Pro 3))', caseSensitive: true);
      
  /// LDAC is an alias for high quality sound preference
  ValueStream<bool> get ldacEnabled => soundQuality.map((q) => q == SoundQualityPreference.quality);
  
  /// Set LDAC enabled (high quality) or disabled (connectivity)
  Future<void> setLdacEnabled(bool enabled) async {
    await setSoundQuality(enabled ? SoundQualityPreference.quality : SoundQualityPreference.connectivity);
  }
}
