import '../../../framework/anc.dart';
import '../../../framework/sound_quality.dart';
import '../settings.dart';

/// Extension to add MBB code conversion for DoubleTap enum
extension DoubleTapMbbCode on DoubleTap {
  int get mbbCode => switch (this) {
        DoubleTap.nothing => 0,
        DoubleTap.voiceAssistant => 1,
        DoubleTap.playPause => 2,
        DoubleTap.next => 3,
        DoubleTap.previous => 4,
      };

  static DoubleTap? fromMbbCode(int code) {
    if (code < 0 || code > 4) return null;
    return DoubleTap.values[code];
  }
}

/// Extension to add MBB code conversion for SoundQualityMode enum
extension SoundQualityModeMbbCode on SoundQualityMode {
  int get mbbCode => switch (this) {
        SoundQualityMode.connectivity => 0,
        SoundQualityMode.quality => 1,
      };

  static SoundQualityMode? fromMbbCode(int code) {
    if (code < 0 || code > 1) return null;
    return SoundQualityMode.values[code];
  }
}

/// Extension to add MBB code conversion for Hold enum
extension HoldMbbCode on Hold {
  int get mbbCode => switch (this) {
        Hold.nothing => 0,
        Hold.cycleAnc => 1,
      };

  static Hold? fromMbbCode(int code) {
    if (code < 0 || code > 1) return null;
    return Hold.values[code];
  }
}

/// Extension to add MBB code conversion for AncMode enum
extension AncModeMbbCode on AncMode {
  int get mbbCode => switch (this) {
        AncMode.noiseCancelling => 1,
        AncMode.off => 0,
        AncMode.transparency => 2,
      };

  static AncMode? fromMbbCode(int code) {
    if (code < 0 || code > 2) return null;
    return AncMode.values[code];
  }
}
