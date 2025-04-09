import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stream_channel/stream_channel.dart';

import '../../mbb.dart';

/// Base class for all headphone features
abstract class HeadphoneFeature {
  /// Unique identifier for the feature
  String get id;

  /// Display name for the feature
  String get displayName;

  /// Check if the feature is supported by the given model
  bool isSupported(bool Function(String featureId) supportCheck);

  /// Initialize the feature
  @mustCallSuper
  void initialize(StreamChannel<MbbCommand> mbb) {
    // Default implementation does nothing
  }

  /// Clean up resources when the feature is no longer needed
  @mustCallSuper
  void dispose() {
    // Default implementation does nothing
  }
}

/// Base class for features that handle MBB commands
abstract class MbbFeature extends HeadphoneFeature {
  /// Process an MBB command
  /// Returns true if the command was handled by this feature
  bool handleMbbCommand(MbbCommand cmd);

  /// Request initial data from the device
  void requestInitialData(StreamChannel<MbbCommand> mbb);
}

/// Base class for features that have settings
abstract class SettingsFeature<T> extends HeadphoneFeature {
  /// Stream of current settings
  ValueStream<T> get settings;

  /// Apply new settings to the device
  Future<void> applySettings(T settings, StreamChannel<MbbCommand> mbb);

  /// Update settings from MBB command
  /// Returns updated settings if the command was handled by this feature
  T? updateSettingsFromMbbCommand(MbbCommand cmd, T currentSettings);
}

/// Base class for MBB features that also have settings
abstract class MbbSettingsFeature<T> extends MbbFeature
    implements SettingsFeature<T> {
  @override
  bool handleMbbCommand(MbbCommand cmd) {
    return false;
  }

  @override
  T? updateSettingsFromMbbCommand(MbbCommand cmd, T currentSettings) {
    return null;
  }
}
