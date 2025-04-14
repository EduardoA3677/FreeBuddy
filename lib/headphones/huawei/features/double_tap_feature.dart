import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stream_channel/stream_channel.dart';

import '../../../logger.dart';
import '../mbb.dart';
import 'base/feature_base.dart';
import 'enums/mbb_codes.dart';
import 'settings.dart';

/// Implementation for double-tap gesture functionality
class DoubleTapFeature extends MbbSettingsFeature<HuaweiHeadphonesSettings> {
  static const featureId = 'double_tap';
  final _settingsCtrl =
      BehaviorSubject<HuaweiHeadphonesSettings>.seeded(const HuaweiHeadphonesSettings());

  /// Command to get current double-tap settings
  static final getDoubleTapCommand = MbbCommand(1, 32);

  @override
  ValueStream<HuaweiHeadphonesSettings> get settings => _settingsCtrl.stream;

  @override
  void dispose() {
    _settingsCtrl.close();
    super.dispose();
  }

  @override
  String get id => featureId;

  @override
  String get displayName => 'Double Tap Gesture';

  @override
  bool isSupported(bool Function(String featureId) supportCheck) {
    return supportCheck(featureId);
  }

  @override
  void requestInitialData(StreamChannel<MbbCommand> mbb) {
    AppLogger.log(LogLevel.debug, "Requesting double tap settings", tag: "MBB:$featureId");
    mbb.sink.add(getDoubleTapCommand);
  }

  @override
  bool handleMbbCommand(MbbCommand cmd) {
    // We don't directly handle the commands here as we only update settings
    return false;
  }

  @override
  HuaweiHeadphonesSettings? updateSettingsFromMbbCommand(
      MbbCommand cmd, HuaweiHeadphonesSettings currentSettings) {
    if (!cmd.isAbout(getDoubleTapCommand)) {
      return null;
    }

    if (cmd.args.containsKey(1) &&
        cmd.args.containsKey(2) &&
        cmd.args[1]!.isNotEmpty &&
        cmd.args[2]!.isNotEmpty) {
      final leftCode = cmd.args[1]![0];
      final rightCode = cmd.args[2]![0];

      return currentSettings.copyWith(
        doubleTapLeft: DoubleTap.values.firstWhereOrNull((e) => e.mbbCode == leftCode),
        doubleTapRight: DoubleTap.values.firstWhereOrNull((e) => e.mbbCode == rightCode),
      );
    }
    return null;
  }

  @override
  Future<void> applySettings(
      HuaweiHeadphonesSettings settings, StreamChannel<MbbCommand> mbb) async {
    // Only apply if current settings have double-tap values
    if (settings.doubleTapLeft != null) {
      AppLogger.log(LogLevel.debug, "Setting double tap left to ${settings.doubleTapLeft}",
          tag: "MBB:$featureId");
      mbb.sink.add(doubleTapCommand(left: settings.doubleTapLeft!));
      mbb.sink.add(getDoubleTapCommand);
    }

    if (settings.doubleTapRight != null) {
      AppLogger.log(LogLevel.debug, "Setting double tap right to ${settings.doubleTapRight}",
          tag: "MBB:$featureId");
      mbb.sink.add(doubleTapCommand(right: settings.doubleTapRight!));
      mbb.sink.add(getDoubleTapCommand);
    }
  }

  /// Creates command to set double-tap gestures
  static MbbCommand doubleTapCommand({DoubleTap? left, DoubleTap? right}) {
    return MbbCommand(1, 31, {
      if (left != null) 1: [left.mbbCode],
      if (right != null) 2: [right.mbbCode],
    });
  }
}
