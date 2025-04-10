import 'package:shared_preferences/shared_preferences.dart';

import '../headphones/framework/bluetooth_headphones.dart';

abstract class AppSettings {
  Stream<bool> get seenIntroduction;

  Future<bool> setSeenIntroduction(bool value);

  Stream<bool> get sleepMode;

  Future<bool> setSleepMode(bool value);

  Stream<String> get sleepModePreviousSettings;

  Future<bool> setSleepModePreviousSettings(String value);

  /// Getter for the current headphones.
  BluetoothHeadphones get currentHeadphones;
}

enum _Prefs {
  seenIntroduction('seenIntroduction', false),
  sleepMode('sleepMode', false),
  sleepModePreviousSettings('sleepModePreviousSettings', '');

  const _Prefs(this.key, this.defaultValue);

  final String key;
  final dynamic defaultValue;
}

class SharedPreferencesAppSettings implements AppSettings {
  final SharedPreferences preferences;

  SharedPreferencesAppSettings(this.preferences);

  @override
  BluetoothHeadphones get currentHeadphones {
    // Replace with actual logic to retrieve the current headphones.
    throw UnimplementedError('currentHeadphones is not implemented yet.');
  }

  @override
  Stream<bool> get seenIntroduction async* {
    yield preferences.getBool(_Prefs.seenIntroduction.key) ?? _Prefs.seenIntroduction.defaultValue;
  }

  @override
  Future<bool> setSeenIntroduction(bool value) async {
    return preferences.setBool(_Prefs.seenIntroduction.key, value);
  }

  @override
  Stream<bool> get sleepMode async* {
    yield preferences.getBool(_Prefs.sleepMode.key) ?? _Prefs.sleepMode.defaultValue;
  }

  @override
  Future<bool> setSleepMode(bool value) async {
    return preferences.setBool(_Prefs.sleepMode.key, value);
  }

  @override
  Stream<String> get sleepModePreviousSettings async* {
    yield preferences.getString(_Prefs.sleepModePreviousSettings.key) ??
        _Prefs.sleepModePreviousSettings.defaultValue;
  }

  @override
  Future<bool> setSleepModePreviousSettings(String value) async {
    return preferences.setString(_Prefs.sleepModePreviousSettings.key, value);
  }
}
