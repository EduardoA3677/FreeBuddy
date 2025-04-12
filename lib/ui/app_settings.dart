import 'package:flutter/material.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:async/async.dart';

abstract class AppSettings {
  Stream<bool> get seenIntroduction;

  Future<bool> setSeenIntroduction(bool value);

  Stream<bool> get sleepMode;

  Future<bool> setSleepMode(bool value);

  Stream<String> get sleepModePreviousSettings;

  Future<bool> setSleepModePreviousSettings(String value);

  /// Modo debug para mostrar logs detallados
  Stream<bool> get debugMode;

  Future<bool> setDebugMode(bool value);

  /// Modo del tema de la aplicación (system, light, dark)
  Stream<ThemeMode> get themeMode;

  Future<bool> setThemeMode(ThemeMode value);
}

enum _Prefs {
  seenIntroduction('seenIntroduction', false),
  sleepMode('sleepMode', false),
  sleepModePreviousSettings('sleepModePreviousSettings', ''),
  debugMode('debugMode', false),
  themeMode('themeMode', 0); // 0 = ThemeMode.system, 1 = ThemeMode.light, 2 = ThemeMode.dark

  const _Prefs(this.key, this.defaultValue);

  final String key;
  final dynamic defaultValue;
}

class SharedPreferencesAppSettings implements AppSettings {
  SharedPreferencesAppSettings(this.preferences);

  final Future<StreamingSharedPreferences> preferences;

  Future<Preference<bool>> get _seenIntroduction => preferences.then((p) =>
      p.getBool(_Prefs.seenIntroduction.key, defaultValue: _Prefs.seenIntroduction.defaultValue));

  Future<Preference<bool>> get _sleepMode => preferences
      .then((p) => p.getBool(_Prefs.sleepMode.key, defaultValue: _Prefs.sleepMode.defaultValue));

  Future<Preference<String>> get _sleepModePreviousSettings =>
      preferences.then((p) => p.getString(_Prefs.sleepModePreviousSettings.key,
          defaultValue: _Prefs.sleepModePreviousSettings.defaultValue));

  Future<Preference<bool>> get _debugMode => preferences
      .then((p) => p.getBool(_Prefs.debugMode.key, defaultValue: _Prefs.debugMode.defaultValue));

  Future<Preference<int>> get _themeMode => preferences
      .then((p) => p.getInt(_Prefs.themeMode.key, defaultValue: _Prefs.themeMode.defaultValue));

  @override
  Stream<bool> get seenIntroduction => LazyStream(() => _seenIntroduction);

  @override
  Future<bool> setSeenIntroduction(bool value) => _seenIntroduction.then((v) => v.setValue(value));

  @override
  Stream<bool> get sleepMode => LazyStream(() => _sleepMode);

  @override
  Future<bool> setSleepMode(bool value) => _sleepMode.then((v) => v.setValue(value));

  @override
  Stream<String> get sleepModePreviousSettings => LazyStream(() => _sleepModePreviousSettings);

  @override
  Future<bool> setSleepModePreviousSettings(String value) =>
      _sleepModePreviousSettings.then((v) => v.setValue(value));

  @override
  Stream<bool> get debugMode => LazyStream(() => _debugMode);

  @override
  Future<bool> setDebugMode(bool value) => _debugMode.then((v) => v.setValue(value));

  @override
  Stream<ThemeMode> get themeMode =>
      LazyStream(() => _themeMode).map((value) => _intToThemeMode(value));

  @override
  Future<bool> setThemeMode(ThemeMode value) =>
      _themeMode.then((pref) => pref.setValue(_themeModeToInt(value)));

  // Convertir de int a ThemeMode
  ThemeMode _intToThemeMode(int value) {
    switch (value) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      case 0:
      case _:
        return ThemeMode.system;
    }
  }

  // Convertir de ThemeMode a int
  int _themeModeToInt(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
      case ThemeMode.system:
        return 0;
    }
  }
}
