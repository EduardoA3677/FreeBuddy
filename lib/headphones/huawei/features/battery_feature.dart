import 'package:rxdart/rxdart.dart';
import 'package:stream_channel/stream_channel.dart';

import '../../framework/lrc_battery.dart';
import '../mbb.dart';
import 'base/feature_base.dart';

/// Implementation for battery reporting functionality
class BatteryFeature extends MbbFeature {
  static const featureId = 'battery';

  final BehaviorSubject<LRCBatteryLevels> _batteryCtrl =
      BehaviorSubject<LRCBatteryLevels>();

  /// Command to get battery information
  static final getBatteryCommand = MbbCommand(1, 8);

  /// Alternative battery command that some models use
  static final alternativeBatteryCommand = MbbCommand(1, 39);

  /// Stream of battery levels
  ValueStream<LRCBatteryLevels> get batteryLevels => _batteryCtrl.stream;

  @override
  String get id => featureId;

  @override
  String get displayName => 'Battery';

  @override
  bool isSupported(bool Function(String featureId) supportCheck) {
    // Battery is always supported
    return true;
  }

  @override
  void requestInitialData(StreamChannel<MbbCommand> mbb) {
    // Request battery info
    mbb.sink.add(getBatteryCommand);
  }

  @override
  bool handleMbbCommand(MbbCommand cmd) {
    if (cmd.serviceId != 1 ||
        (cmd.commandId != 8 && cmd.commandId != 39) ||
        !cmd.args.containsKey(2) ||
        !cmd.args.containsKey(3)) {
      return false;
    }

    final level = cmd.args[2]!;
    final status = cmd.args[3]!;

    if (level.length >= 3 && status.length >= 3) {
      _batteryCtrl.add(LRCBatteryLevels(
        level[0] == 0 ? null : level[0],
        level[1] == 0 ? null : level[1],
        level[2] == 0 ? null : level[2],
        status[0] == 1,
        status[1] == 1,
        status[2] == 1,
      ));
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    _batteryCtrl.close();
    super.dispose();
  }
}
