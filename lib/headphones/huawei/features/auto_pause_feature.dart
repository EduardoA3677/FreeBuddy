import 'package:rxdart/rxdart.dart';
import 'package:stream_channel/stream_channel.dart';

import '../../../logger.dart';
import '../mbb.dart';
import 'base/feature_base.dart';
import 'settings.dart';

/// Implementation for auto-pause functionality
class AutoPauseFeature extends MbbSettingsFeature<HuaweiHeadphonesSettings> {
  static const featureId = 'auto_pause';
  final _settingsCtrl =
      BehaviorSubject<HuaweiHeadphonesSettings>.seeded(const HuaweiHeadphonesSettings());

  @override
  ValueStream<HuaweiHeadphonesSettings> get settings => _settingsCtrl.stream;

  /// Command to get auto-pause setting
  static final getAutoPauseCommand = MbbCommand(43, 17);

  @override
  void dispose() {
    _settingsCtrl.close();
    super.dispose();
  }

  @override
  String get id => featureId;

  @override
  String get displayName => 'Auto Pause';

  @override
  bool isSupported(bool Function(String featureId) supportCheck) {
    return supportCheck(featureId);
  }

  @override
  void requestInitialData(StreamChannel<MbbCommand> mbb) {
    AppLogger.log(LogLevel.debug, "Requesting auto pause settings", tag: "MBB:$featureId");
    mbb.sink.add(getAutoPauseCommand);
  }

  @override
  bool handleMbbCommand(MbbCommand cmd) {
    // We don't directly handle the commands here as we only update settings
    return false;
  }

  @override
  HuaweiHeadphonesSettings? updateSettingsFromMbbCommand(
      MbbCommand cmd, HuaweiHeadphonesSettings currentSettings) {
    if (!cmd.isAbout(getAutoPauseCommand)) {
      return null;
    }

    if (cmd.args.containsKey(1) && cmd.args[1]!.isNotEmpty) {
      final autoPauseCode = cmd.args[1]![0];
      return currentSettings.copyWith(autoPause: autoPauseCode == 1);
    }

    return null;
  }

  @override
  Future<void> applySettings(
      HuaweiHeadphonesSettings settings, StreamChannel<MbbCommand> mbb) async {
    if (settings.autoPause != null) {
      mbb.sink.add(setAutoPauseCommand(settings.autoPause!));
      mbb.sink.add(getAutoPauseCommand);
    }
  }

  /// Creates command to set auto-pause
  static MbbCommand setAutoPauseCommand(bool enabled) {
    return MbbCommand(43, 16, {
      1: [enabled ? 1 : 0]
    });
  }
}
