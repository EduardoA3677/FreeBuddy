import 'package:stream_channel/stream_channel.dart';

import '../mbb.dart';
import 'settings.dart';

/// Implementation for auto-pause functionality
class AutoPauseImplementation {
  /// Command to get auto-pause setting
  static final getAutoPauseCommand = MbbCommand(43, 17);

  /// Creates command to set auto-pause
  static MbbCommand setAutoPauseCommand(bool enabled) {
    return MbbCommand(43, 16, {
      1: [enabled ? 1 : 0]
    });
  }

  /// Processes auto-pause updates from device
  static HuaweiHeadphonesSettings? handleAutoPauseUpdate(
      MbbCommand cmd, HuaweiHeadphonesSettings lastSettings) {
    if (!cmd.isAbout(getAutoPauseCommand)) {
      return null;
    }

    if (cmd.args.containsKey(1) && cmd.args[1]!.isNotEmpty) {
      final autoPauseCode = cmd.args[1]![0];
      return lastSettings.copyWith(autoPause: autoPauseCode == 1);
    }

    return null;
  }

  /// Applies auto-pause settings to device
  static void applyAutoPauseSettings(
    StreamChannel<MbbCommand> mbb,
    HuaweiHeadphonesSettings prev,
    HuaweiHeadphonesSettings newSettings,
  ) {
    if ((newSettings.autoPause ?? prev.autoPause) != prev.autoPause) {
      mbb.sink.add(setAutoPauseCommand(newSettings.autoPause!));
      mbb.sink.add(getAutoPauseCommand);
    }
  }
}
