import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

import '../../framework/anc.dart';
import '../mbb.dart';

/// Implementation for Active Noise Cancelling functionality
class AncImplementation {
  /// Command to get current ANC mode
  static final getAncCommand = MbbCommand(43, 42);

  /// Creates command to set ANC mode
  static MbbCommand setAncCommand(AncMode mode) {
    return MbbCommand(43, 4, {
      1: [mode.mbbCode, mode == AncMode.off ? 0 : 255]
    });
  }

  /// Processes ANC mode updates from device
  static bool handleAncUpdate(
      MbbCommand cmd, BehaviorSubject<AncMode> ancModeCtrl) {
    if (!cmd.isAbout(getAncCommand) ||
        !cmd.args.containsKey(1) ||
        cmd.args[1]!.length < 2) {
      return false;
    }

    final ancModeCode = cmd.args[1]![1];
    final mode =
        AncMode.values.firstWhereOrNull((e) => e.mbbCode == ancModeCode);

    if (mode != null) {
      ancModeCtrl.add(mode);
      return true;
    }

    return false;
  }
}

/// Extension to add MBB code conversion for AncMode enum
extension AncModeToMbbCode on AncMode {
  int get mbbCode => switch (this) {
        AncMode.noiseCancelling => 1,
        AncMode.off => 0,
        AncMode.transparency => 2,
      };
}
