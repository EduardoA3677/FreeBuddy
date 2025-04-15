import '../../framework/anc.dart';
import '../../framework/sound_quality.dart';

/// Common settings for all Huawei headphones models
class HuaweiHeadphonesSettings {
  final DoubleTap? doubleTapLeft;
  final DoubleTap? doubleTapRight;
  final Hold? holdBoth;
  final Set<AncMode>? holdBothToggledAncModes;
  final bool? autoPause;
  final SoundQualityMode? soundQuality;

  const HuaweiHeadphonesSettings({
    this.doubleTapLeft,
    this.doubleTapRight,
    this.holdBoth,
    this.holdBothToggledAncModes,
    this.autoPause,
    this.soundQuality,
  });

  // don't want to use codegen *yet*
  HuaweiHeadphonesSettings copyWith({
    DoubleTap? doubleTapLeft,
    DoubleTap? doubleTapRight,
    Hold? holdBoth,
    Set<AncMode>? holdBothToggledAncModes,
    bool? autoPause,
    SoundQualityMode? soundQuality,
  }) =>
      HuaweiHeadphonesSettings(
        doubleTapLeft: doubleTapLeft ?? this.doubleTapLeft,
        doubleTapRight: doubleTapRight ?? this.doubleTapRight,
        holdBoth: holdBoth ?? this.holdBoth,
        holdBothToggledAncModes: holdBothToggledAncModes ?? this.holdBothToggledAncModes,
        autoPause: autoPause ?? this.autoPause,
        soundQuality: soundQuality ?? this.soundQuality,
      );
}

// i don't have idea how to public/privatise those and how to name them
// let's assume that any screen/logic that uses them at all is already
// model-specific so generic names are okay

enum DoubleTap {
  nothing,
  voiceAssistant,
  playPause,
  next,
  previous;
}

enum Hold {
  nothing,
  cycleAnc;
}
