import '../../../headphones/framework/anc.dart';

/// Common settings structure for Huawei headphones
class HuaweiHeadphonesSettings {
  final DoubleTap? doubleTapLeft;
  final DoubleTap? doubleTapRight;
  final Hold? holdBoth;
  final Set<AncMode>? holdBothToggledAncModes;
  final bool? autoPause;

  const HuaweiHeadphonesSettings({
    this.doubleTapLeft,
    this.doubleTapRight,
    this.holdBoth,
    this.holdBothToggledAncModes,
    this.autoPause,
  });

  /// Creates a new copy with specific fields updated
  HuaweiHeadphonesSettings copyWith({
    DoubleTap? doubleTapLeft,
    DoubleTap? doubleTapRight,
    Hold? holdBoth,
    Set<AncMode>? holdBothToggledAncModes,
    bool? autoPause,
  }) =>
      HuaweiHeadphonesSettings(
        doubleTapLeft: doubleTapLeft ?? this.doubleTapLeft,
        doubleTapRight: doubleTapRight ?? this.doubleTapRight,
        holdBoth: holdBoth ?? this.holdBoth,
        holdBothToggledAncModes:
            holdBothToggledAncModes ?? this.holdBothToggledAncModes,
        autoPause: autoPause ?? this.autoPause,
      );
}

/// Double-tap gesture actions
enum DoubleTap {
  nothing,
  voiceAssistant,
  playPause,
  next,
  previous;
}

/// Hold gesture actions
enum Hold {
  nothing,
  cycleAnc;
}
