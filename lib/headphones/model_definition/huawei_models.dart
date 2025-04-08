import '../framework/anc.dart';
import '../huawei/features/settings.dart';
import 'huawei_models_definition.dart';

/// In-ear detection feature
class InEarDetection {
  static const serviceId = 43;
  static const commandId = 3;
}

/// Collection of supported Huawei headphones models
class HuaweiModels {
  /// FreeBuds Pro 3 model definition
  static final freeBudsPro3 = HuaweiModelDefinition(
    name: "FreeBuds Pro 3",
    idNameRegex: RegExp(r'^(?=(HUAWEI FreeBuds Pro 3))', caseSensitive: true),
    imageAssetPath:
        'assets/app_icons/ic_launcher.png', // Update with actual path
    supportsAnc: true,
    supportsDoubleTap: true,
    supportsHold: true,
    supportsAutoPause: true,
    defaultSettings: const HuaweiHeadphonesSettings(
      doubleTapLeft: DoubleTap.playPause,
      doubleTapRight: DoubleTap.playPause,
      holdBoth: Hold.cycleAnc,
      holdBothToggledAncModes: {
        AncMode.noiseCancelling,
        AncMode.off,
        AncMode.transparency,
      },
      autoPause: true,
    ),
  );

  /// FreeBuds 4i model definition
  static final freeBuds4i = HuaweiModelDefinition(
    name: "FreeBuds 4i",
    idNameRegex: RegExp(r'^(?=(HUAWEI FreeBuds 4i))', caseSensitive: true),
    imageAssetPath:
        'assets/app_icons/ic_launcher.png', // Update with actual path
    supportsAnc: true,
    supportsDoubleTap: true,
    supportsHold: true,
    supportsAutoPause: false, // FreeBuds 4i doesn't support auto-pause settings
    defaultSettings: const HuaweiHeadphonesSettings(
      doubleTapLeft: DoubleTap.playPause,
      doubleTapRight: DoubleTap.playPause,
      holdBoth: Hold.cycleAnc,
      holdBothToggledAncModes: {
        AncMode.noiseCancelling,
        AncMode.off,
      },
      autoPause: null,
    ),
  );

  /// List of all available models for easier matching
  static final List<HuaweiModelDefinition> allModels = [
    freeBudsPro3,
    freeBuds4i,
  ];
}
