import 'package:collection/collection.dart';
import 'package:stream_channel/stream_channel.dart';

import '../mbb.dart';
import 'settings.dart';

/// Implementation for double-tap gesture functionality
class DoubleTapImplementation {
  /// Command to get current double-tap settings
  static final getDoubleTapCommand = MbbCommand(1, 32);

  /// Creates command to set double-tap gestures
  static MbbCommand doubleTapCommand({DoubleTap? left, DoubleTap? right}) {
    return MbbCommand(1, 31, {
      if (left != null) 1: [left.mbbCode],
      if (right != null) 2: [right.mbbCode],
    });
  }

  /// Processes double-tap settings update from device
  static HuaweiHeadphonesSettings? handleDoubleTapUpdate(
      MbbCommand cmd, HuaweiHeadphonesSettings lastSettings) {
    if (!cmd.isAbout(getDoubleTapCommand)) {
      return null;
    }

    if (cmd.args.containsKey(1) &&
        cmd.args.containsKey(2) &&
        cmd.args[1]!.isNotEmpty &&
        cmd.args[2]!.isNotEmpty) {
      final leftCode = cmd.args[1]![0];
      final rightCode = cmd.args[2]![0];

      return lastSettings.copyWith(
        doubleTapLeft:
            DoubleTap.values.firstWhereOrNull((e) => e.mbbCode == leftCode),
        doubleTapRight:
            DoubleTap.values.firstWhereOrNull((e) => e.mbbCode == rightCode),
      );
    }
    return null;
  }

  /// Applies double-tap settings to device
  static void applyDoubleTapSettings(
    StreamChannel<MbbCommand> mbb,
    HuaweiHeadphonesSettings prev,
    HuaweiHeadphonesSettings newSettings,
  ) {
    // Update left double-tap if changed
    if ((newSettings.doubleTapLeft ?? prev.doubleTapLeft) !=
        prev.doubleTapLeft) {
      mbb.sink.add(doubleTapCommand(left: newSettings.doubleTapLeft!));
      mbb.sink.add(getDoubleTapCommand);
    }

    // Update right double-tap if changed
    if ((newSettings.doubleTapRight ?? prev.doubleTapRight) !=
        prev.doubleTapRight) {
      mbb.sink.add(doubleTapCommand(right: newSettings.doubleTapRight!));
      mbb.sink.add(getDoubleTapCommand);
    }
  }
}

/// Extension to add MBB code conversion for DoubleTap enum
extension DoubleTapToMbbCode on DoubleTap {
  int get mbbCode => switch (this) {
        DoubleTap.nothing => 255,
        DoubleTap.voiceAssistant => 0,
        DoubleTap.playPause => 1,
        DoubleTap.next => 2,
        DoubleTap.previous => 7
      };
}
