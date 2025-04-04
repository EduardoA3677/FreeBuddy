import '../framework/anc.dart';

class HuaweiFreeBudsPro3Settings {
  // hey hey hay, not only settings are gonna be duplicate spaghetti shithole,
  // but all the fields are gonna be nullable too!
  final DoubleTap? doubleTapLeft;
  final DoubleTap? doubleTapRight;
  final Hold? holdBoth;
  final Set<AncMode>? holdBothToggledAncModes;

  final bool? autoPause;
  final bool? lowLatency;
  final bool? ldac;  // true = quality mode, false = connectivity mode

  const HuaweiFreeBudsPro3Settings({
    this.doubleTapLeft,
    this.doubleTapRight,
    this.holdBoth,
    this.holdBothToggledAncModes,
    this.autoPause,
    this.lowLatency,
    this.ldac,
  });

  // don't want to use codegen *yet*
  HuaweiFreeBudsPro3Settings copyWith({
    DoubleTap? doubleTapLeft,
    DoubleTap? doubleTapRight,
    Hold? holdBoth,
    Set<AncMode>? holdBothToggledAncModes,
    bool? autoPause,
    bool? lowLatency,
    bool? ldac,
  }) =>
      HuaweiFreeBudsPro3Settings(
        doubleTapLeft: doubleTapLeft ?? this.doubleTapLeft,
        doubleTapRight: doubleTapRight ?? this.doubleTapRight,
        holdBoth: holdBoth ?? this.holdBoth,
        holdBothToggledAncModes:
            holdBothToggledAncModes ?? this.holdBothToggledAncModes,
        autoPause: autoPause ?? this.autoPause,
        lowLatency: lowLatency ?? this.lowLatency,
        ldac: ldac ?? this.ldac,
      );
}

class HuaweiFreeBuds3iSettings {
  // hey hey hay, not only settings are gonna be duplicate spaghetti shithole,
  // but all the fields are gonna be nullable too!
  final DoubleTap? doubleTapLeft;
  final DoubleTap? doubleTapRight;

  // those are luckily same as Pro3
  final Hold? holdBoth;
  final Set<AncMode>? holdBothToggledAncModes;

  // They do have auto-pause... but it's not settable from app 🤷
  // but we may find it some day! That's why I'm commenting it out
            // final bool? autoPause;

  const HuaweiFreeBuds3iSettings({
    this.doubleTapLeft,
    this.doubleTapRight,
    this.holdBoth,
    this.holdBothToggledAncModes,
    // this.autoPause,
  });

  // don't want to use codegen *yet*
  HuaweiFreeBuds3iSettings copyWith({
    DoubleTap? doubleTapLeft,
    DoubleTap? doubleTapRight,
    Hold? holdBoth,
    Set<AncMode>? holdBothToggledAncModes,
    // bool? autoPause,
  }) =>
      HuaweiFreeBuds3iSettings(
        doubleTapLeft: doubleTapLeft ?? this.doubleTapLeft,
        doubleTapRight: doubleTapRight ?? this.doubleTapRight,
        holdBoth: holdBoth ?? this.holdBoth,
        holdBothToggledAncModes:
            holdBothToggledAncModes ?? this.holdBothToggledAncModes,
        // autoPause: autoPause ?? this.autoPause,
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
