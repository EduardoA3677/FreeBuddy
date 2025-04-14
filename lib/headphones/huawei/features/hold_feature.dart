import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stream_channel/stream_channel.dart';

import '../../../logger.dart';
import '../../framework/anc.dart';
import '../mbb.dart';
import 'base/feature_base.dart';
import 'enums/mbb_codes.dart';
import 'settings.dart';

/// Implementation for hold gesture functionality
class HoldFeature extends MbbSettingsFeature<HuaweiHeadphonesSettings> {
  static const featureId = 'hold';
  final _settingsCtrl = BehaviorSubject<HuaweiHeadphonesSettings>.seeded(
      const HuaweiHeadphonesSettings());

  @override
  ValueStream<HuaweiHeadphonesSettings> get settings => _settingsCtrl.stream;

  /// Command to get hold gesture settings
  static final getHoldCommand = MbbCommand(43, 23);

  @override
  void dispose() {
    _settingsCtrl.close();
    super.dispose();
  }

  /// Command to get which ANC modes toggle with hold
  static final getHoldToggledModesCommand = MbbCommand(43, 25);

  @override
  String get id => featureId;

  @override
  String get displayName => 'Hold Gesture';

  @override
  bool isSupported(bool Function(String featureId) supportCheck) {
    return supportCheck(featureId);
  }

  @override
  void requestInitialData(StreamChannel<MbbCommand> mbb) {
    mbb.sink.add(getHoldCommand);
    mbb.sink.add(getHoldToggledModesCommand);
  }

  @override
  bool handleMbbCommand(MbbCommand cmd) {
    // We don't directly handle the commands here as we only update settings
    return false;
  }

  @override
  HuaweiHeadphonesSettings? updateSettingsFromMbbCommand(
      MbbCommand cmd, HuaweiHeadphonesSettings currentSettings) {
    // Handle hold gesture updates
    if (cmd.isAbout(getHoldCommand) &&
        cmd.args.containsKey(1) &&
        cmd.args[1]!.isNotEmpty) {
      final holdCode = cmd.args[1]![0];
      return currentSettings.copyWith(
        holdBoth: Hold.values.firstWhereOrNull((e) => e.mbbCode == holdCode),
      );
    }

    // Handle hold toggled modes updates
    if (cmd.isAbout(getHoldToggledModesCommand) &&
        cmd.args.containsKey(1) &&
        cmd.args[1]!.isNotEmpty) {
      final modesCode = cmd.args[1]![0];
      return currentSettings.copyWith(
        holdBothToggledAncModes: holdToggledAncModesFromMbbValue(modesCode),
      );
    }

    return null;
  }

  @override
  Future<void> applySettings(
      HuaweiHeadphonesSettings settings, StreamChannel<MbbCommand> mbb) async {
    // Apply hold gesture settings
    if (settings.holdBoth != null) {
      mbb.sink.add(setHoldCommand(settings.holdBoth!));
      mbb.sink.add(getHoldCommand);
    }

    // Apply toggled modes settings
    if (settings.holdBothToggledAncModes != null) {
      mbb.sink
          .add(setHoldToggledModesCommand(settings.holdBothToggledAncModes!));
      mbb.sink.add(getHoldCommand);
      mbb.sink.add(getHoldToggledModesCommand);
    }
  }

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
      AppLogger.log(
          LogLevel.warning,
          "Unknown mbbValue for $toggledModes"
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
}
