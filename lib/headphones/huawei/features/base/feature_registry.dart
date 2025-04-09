import 'package:collection/collection.dart';
import 'package:stream_channel/stream_channel.dart';

import '../../mbb.dart';
import '../settings.dart';
import 'feature_base.dart';

/// Registry for all available features
class FeatureRegistry {
  final List<HeadphoneFeature> _features = [];
  final List<MbbFeature> _mbbFeatures = [];
  final Map<String, SettingsFeature> _settingsFeatures = {};
  final StreamChannel<MbbCommand> _mbb;
  final bool Function(String featureId) _supportCheck;

  FeatureRegistry({
    required StreamChannel<MbbCommand> mbb,
    required bool Function(String featureId) supportCheck,
  })  : _mbb = mbb,
        _supportCheck = supportCheck;

  /// Register a feature
  void registerFeature(HeadphoneFeature feature) {
    if (feature.isSupported(_supportCheck)) {
      _features.add(feature);
      feature.initialize(_mbb);

      if (feature is MbbFeature) {
        _mbbFeatures.add(feature);
        feature.requestInitialData(_mbb);
      }

      if (feature is SettingsFeature) {
        _settingsFeatures[feature.id] = feature;
      }
    }
  }

  bool isFeatureSupported(String featureId) {
    return _supportCheck(featureId);
  }

  /// Register multiple features
  void registerFeatures(List<HeadphoneFeature> features) {
    for (final feature in features) {
      registerFeature(feature);
    }
  }

  /// Get a specific feature by ID
  T? getFeature<T extends HeadphoneFeature>(String id) {
    return _features.firstWhereOrNull((f) => f.id == id) as T?;
  }

  /// Get all features of a specific type
  List<T> getFeaturesByType<T extends HeadphoneFeature>() {
    return _features.whereType<T>().toList();
  }

  /// Handle incoming MBB command
  void handleMbbCommand(MbbCommand cmd) {
    for (final feature in _mbbFeatures) {
      if (feature.handleMbbCommand(cmd)) {
        break; // Command handled, no need to continue
      }
    }
  }

  /// Update settings from MBB command
  HuaweiHeadphonesSettings? updateSettings(
      MbbCommand cmd, HuaweiHeadphonesSettings settings) {
    HuaweiHeadphonesSettings? updatedSettings;

    for (final feature in _settingsFeatures.values) {
      if (feature is SettingsFeature<HuaweiHeadphonesSettings>) {
        final result = feature.updateSettingsFromMbbCommand(
            cmd, updatedSettings ?? settings);
        if (result != null) {
          updatedSettings = result;
        }
      }
    }

    return updatedSettings;
  }

  /// Apply all settings
  Future<void> applySettings(HuaweiHeadphonesSettings settings) async {
    for (final feature in _settingsFeatures.values) {
      if (feature is SettingsFeature<HuaweiHeadphonesSettings>) {
        await feature.applySettings(settings, _mbb);
      }
    }
  }

  /// Clean up all features
  void dispose() {
    for (final feature in _features) {
      feature.dispose();
    }
    _features.clear();
    _mbbFeatures.clear();
    _settingsFeatures.clear();
  }
}
