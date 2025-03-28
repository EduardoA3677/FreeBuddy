import 'package:rxdart/rxdart.dart';

import '../framework/anc.dart';
import '../framework/bluetooth_headphones.dart';
import '../framework/headphones_info.dart';
import '../framework/headphones_settings.dart';
import '../framework/lrc_battery.dart';
import 'settings.dart';

/// Base abstract class of Pro 3's. It contains static info like vendor names etc,
/// but no logic whatsoever.
///
/// It makes both a solid ground for actual implementation (by defining what
/// features they implement), and some basic info for easy simulation.
abstract base class HuaweiFreeBudsPro3
    implements BluetoothHeadphones, HeadphonesModelInfo, LRCBattery, Anc {
  const HuaweiFreeBudsPro3();

  @override
  String get vendor => "Huawei";

  @override
  String get name => "FreeBuds Pro 3";

  @override
  ValueStream<String> get imageAssetPath =>
      BehaviorSubject.seeded('assets/app_icons/ic_launcher.png');

  static final idNameRegex =
      RegExp(r'^(?=(HUAWEI FreeBuds Pro 3))', caseSensitive: true);
}