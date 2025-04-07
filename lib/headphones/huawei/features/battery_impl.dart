import 'package:rxdart/rxdart.dart';

import '../../framework/lrc_battery.dart';
import '../mbb.dart';

/// Implementation for battery reporting functionality
class BatteryImplementation {
  /// Command to get battery information
  static final getBatteryCommand = MbbCommand(1, 8);

  /// Alternative battery command that some models use
  static final alternativeBatteryCommand = MbbCommand(1, 39);

  /// Processes battery updates from device
  static bool handleBatteryUpdate(
      MbbCommand cmd, BehaviorSubject<LRCBatteryLevels> batteryCtrl) {
    if (cmd.serviceId != 1 ||
        (cmd.commandId != 8 && cmd.commandId != 39) ||
        !cmd.args.containsKey(2) ||
        !cmd.args.containsKey(3)) {
      return false;
    }

    final level = cmd.args[2]!;
    final status = cmd.args[3]!;

    if (level.length >= 3 && status.length >= 3) {
      batteryCtrl.add(LRCBatteryLevels(
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
}
