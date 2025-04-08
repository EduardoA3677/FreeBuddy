import 'package:collection/collection.dart';
import 'package:stream_channel/stream_channel.dart';

import '../../../logger.dart';
import '../../framework/anc.dart';
import '../mbb.dart';
import 'settings.dart';

/// Implementation for hold gesture functionality
class HoldFeature {
  /// Command to get hold gesture settings
  static final getHoldCommand = MbbCommand(43, 23);

  /// Command to get which ANC modes toggle with hold
  static final getHoldToggledModesCommand = MbbCommand(43, 25);

  /// Creates command to set hold gesture
  static MbbCommand setHoldCommand(Hold gestureHold) {
    return MbbCommand(43, 22, {
      1: [gestureHold.mbbCode]
    });
  }

  /// Creates command to set which ANC modes toggle with hold
  static MbbCommand setHoldToggledModesCommand(Set<AncMode> toggledModes) {
    int? mbbValue;
    const se = SetEquality();

    // Determine MBB value based on toggle modes selected
    if (se.equals(toggledModes, {AncMode.off, AncMode.noiseCancelling})) {
      mbbValue = 1;
    }
    if (toggledModes.length == 3) mbbValue = 2;
    if (se.equals(
        toggledModes, {AncMode.noiseCancelling, AncMode.transparency})) {
      mbbValue = 3;
    }
    if (se.equals(toggledModes, {AncMode.off, AncMode.transparency})) {
      mbbValue = 4;
    }

    if (mbbValue == null) {
      logg.w("Unknown mbbValue for $toggledModes"
          " - setting as 2 for 'all of them' as a recovery");
      mbbValue = 2;
    }

    return MbbCommand(43, 24, {
      1: [mbbValue],
      2: [mbbValue]
    });
  }

  /// Converts MBB value to a set of ANC modes
  static Set<AncMode>? holdToggledAncModesFromMbbValue(int mbbValue) {
    return switch (mbbValue) {
      1 => {AncMode.off, AncMode.noiseCancelling},
      2 => AncMode.values.toSet(),
      3 => {AncMode.noiseCancelling, AncMode.transparency},
      4 => {AncMode.off, AncMode.transparency},
      _ => null,
    };
  }

  /// Processes hold gesture updates from device
  static HuaweiHeadphonesSettings? handleHoldUpdate(
      MbbCommand cmd, HuaweiHeadphonesSettings lastSettings) {
    if (!cmd.isAbout(getHoldCommand)) {
      return null;
    }

    if (cmd.args.containsKey(1) && cmd.args[1]!.isNotEmpty) {
      final holdCode = cmd.args[1]![0];
      return lastSettings.copyWith(
        holdBoth: Hold.values.firstWhereOrNull((e) => e.mbbCode == holdCode),
      );
    }

    return null;
  }

  /// Processes hold toggled modes updates from device
  static HuaweiHeadphonesSettings? handleHoldToggledModesUpdate(
      MbbCommand cmd, HuaweiHeadphonesSettings lastSettings) {
    if (!cmd.isAbout(getHoldToggledModesCommand)) {
      return null;
    }

    if (cmd.args.containsKey(1) && cmd.args[1]!.isNotEmpty) {
      final modesCode = cmd.args[1]![0];
      return lastSettings.copyWith(
        holdBothToggledAncModes: holdToggledAncModesFromMbbValue(modesCode),
      );
    }

    return null;
  }

  /// Applies hold settings to device
  static void applyHoldSettings(
    StreamChannel<MbbCommand> mbb,
    HuaweiHeadphonesSettings prev,
    HuaweiHeadphonesSettings newSettings,
  ) {
    // Update hold gesture if changed
    if ((newSettings.holdBoth ?? prev.holdBoth) != prev.holdBoth) {
      mbb.sink.add(setHoldCommand(newSettings.holdBoth!));
      mbb.sink.add(getHoldCommand);
      mbb.sink.add(getHoldToggledModesCommand);
    }

    // Update toggled modes if changed
    if ((newSettings.holdBothToggledAncModes ?? prev.holdBothToggledAncModes) !=
        prev.holdBothToggledAncModes) {
      mbb.sink.add(
          setHoldToggledModesCommand(newSettings.holdBothToggledAncModes!));
      mbb.sink.add(getHoldCommand);
      mbb.sink.add(getHoldToggledModesCommand);
    }
  }
}

/// Extension to add MBB code conversion for Hold enum
extension HoldToMbbCode on Hold {
  int get mbbCode => switch (this) {
        Hold.nothing => 255,
        Hold.cycleAnc => 10,
      };
}
