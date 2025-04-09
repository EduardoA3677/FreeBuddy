import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stream_channel/stream_channel.dart';

import '../../framework/anc.dart';
import '../mbb.dart';
import 'base/feature_base.dart';

/// Implementation for Active Noise Cancelling functionality
class AncFeature extends MbbFeature {
  static const featureId = 'anc';

  final BehaviorSubject<AncMode> _ancModeCtrl = BehaviorSubject<AncMode>();

  /// Command to get current ANC mode
  static final getAncCommand = MbbCommand(43, 42);

  /// Stream of current ANC mode
  ValueStream<AncMode> get ancMode => _ancModeCtrl.stream;

  /// Creates command to set ANC mode
  static MbbCommand setAncCommand(AncMode mode) {
    return MbbCommand(43, 4, {
      1: [mode.mbbCode, mode == AncMode.off ? 0 : 255]
    });
  }

  @override
  String get id => featureId;

  @override
  String get displayName => 'Active Noise Cancellation';

  @override
  bool isSupported(bool Function(String featureId) supportCheck) {
    return supportCheck(featureId);
  }

  @override
  void requestInitialData(StreamChannel<MbbCommand> mbb) {
    // Request current ANC mode
    mbb.sink.add(getAncCommand);
  }

  @override
  bool handleMbbCommand(MbbCommand cmd) {
    if (!cmd.isAbout(getAncCommand) ||
        !cmd.args.containsKey(1) ||
        cmd.args[1]!.length < 2) {
      return false;
    }

    final ancModeCode = cmd.args[1]![1];
    final mode =
        AncMode.values.firstWhereOrNull((e) => e.mbbCode == ancModeCode);

    if (mode != null) {
      _ancModeCtrl.add(mode);
      return true;
    }

    return false;
  }

  /// Set ANC mode
  Future<void> setMode(AncMode mode, StreamChannel<MbbCommand> mbb) async {
    mbb.sink.add(setAncCommand(mode));
    // Request updated status after setting
    mbb.sink.add(getAncCommand);
  }

  @override
  void dispose() {
    _ancModeCtrl.close();
    super.dispose();
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
