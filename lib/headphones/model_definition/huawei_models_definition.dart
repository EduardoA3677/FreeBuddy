import '../framework/anc.dart';
import '../huawei/features/settings.dart';

/// Definition of a Huawei headphones model with its capabilities
class HuaweiModelDefinition {
  final String name;
  final String vendor;
  final RegExp idNameRegex;
  final String imageAssetPath;
  final bool supportsAnc;
  final bool supportsDoubleTap;
  final bool supportsHold;
  final bool supportsAutoPause;
  final bool supportsInEarDetection;
  final HuaweiHeadphonesSettings defaultSettings;

  const HuaweiModelDefinition({
    required this.name,
    required this.vendor,
    required this.idNameRegex,
    required this.imageAssetPath,
    this.supportsAnc = false,
    this.supportsDoubleTap = false,
    this.supportsHold = false,
    this.supportsAutoPause = false,
    this.supportsInEarDetection = false,
    required this.defaultSettings,
  });
}

/// Collection of supported Huawei headphone models
class HuaweiModels {
  /// FreeBuds Pro 3 model definition
  static final freeBudsPro3 = HuaweiModelDefinition(
    name: "FreeBuds Pro 3",
    vendor: "Huawei",
    idNameRegex: RegExp(r'^(?=(HUAWEI FreeBuds Pro 3))', caseSensitive: true),
    imageAssetPath: 'assets/app_icons/ic_launcher.png',
    supportsAnc: true,
    supportsDoubleTap: true,
    supportsHold: true,
    supportsAutoPause: true,
    supportsInEarDetection: true,
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
    vendor: "Huawei",
    idNameRegex: RegExp(r'^(?=(HUAWEI FreeBuds 4i))', caseSensitive: true),
    imageAssetPath: 'assets/app_icons/ic_launcher.png',
    supportsAnc: true,
    supportsDoubleTap: true,
    supportsHold: true,
    supportsAutoPause: false, // 4i doesn't support auto-pause settings
    supportsInEarDetection: true,
    defaultSettings: const HuaweiHeadphonesSettings(
      doubleTapLeft: DoubleTap.playPause,
      doubleTapRight: DoubleTap.playPause,
      holdBoth: Hold.cycleAnc,
      holdBothToggledAncModes: {
        AncMode.noiseCancelling,
        AncMode.off,
        AncMode.transparency,
      },
      autoPause: null,
    ),
  );

  /// List of all supported models
  static final List<HuaweiModelDefinition> allModels = [
    freeBudsPro3,
    freeBuds4i,
  ];

  /// Find a model definition by device name
  static HuaweiModelDefinition findModelByName(String deviceName) {
    return allModels.firstWhere(
      (model) => model.idNameRegex.hasMatch(deviceName),
      orElse: () => throw Exception("Unsupported model: $deviceName"),
    );
  }
}
