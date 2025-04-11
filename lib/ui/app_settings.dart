import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../headphones/framework/bluetooth_headphones.dart';
import '../headphones/huawei/huawei_headphones_sim.dart';
import '../headphones/model_definition/huawei_models_definition.dart';

abstract class AppSettings {
  Stream<bool> get seenIntroduction;

  Future<bool> setSeenIntroduction(bool value);

  Stream<bool> get sleepMode;

  Future<bool> setSleepMode(bool value);

  Stream<String> get sleepModePreviousSettings;

  Future<bool> setSleepModePreviousSettings(String value);

  /// Getter for the current headphones.
  BluetoothHeadphones get currentHeadphones;

  /// Tema de la aplicación
  Stream<ThemeMode> get themeMode;

  Future<bool> setThemeMode(ThemeMode value);

  /// Modo debug para mostrar logs detallados
  Stream<bool> get debugMode;

  Future<bool> setDebugMode(bool value);
}

enum _Prefs {
  seenIntroduction('seenIntroduction', false),
  sleepMode('sleepMode', false),
  sleepModePreviousSettings('sleepModePreviousSettings', ''),
  themeMode('themeMode', 0), // 0 = ThemeMode.system
  debugMode('debugMode', false);

  const _Prefs(this.key, this.defaultValue);

  final String key;
  final dynamic defaultValue;
}

class SharedPreferencesAppSettings implements AppSettings {
  final SharedPreferences preferences;

  SharedPreferencesAppSettings(this.preferences);
  @override
  BluetoothHeadphones get currentHeadphones {
    // Using FreeBuds Pro 3 model as requested
    return HuaweiHeadphonesSim(HuaweiModels.freeBudsPro3);
  }

  @override
  Stream<bool> get seenIntroduction async* {
    yield preferences.getBool(_Prefs.seenIntroduction.key) ?? _Prefs.seenIntroduction.defaultValue;
  }

  @override
  Stream<ThemeMode> get themeMode async* {
    final value = preferences.getInt(_Prefs.themeMode.key) ?? _Prefs.themeMode.defaultValue;
    yield ThemeMode.values[value];
  }

  @override
  Future<bool> setThemeMode(ThemeMode value) async {
    return preferences.setInt(_Prefs.themeMode.key, value.index);
  }

  @override
  Stream<bool> get debugMode async* {
    yield preferences.getBool(_Prefs.debugMode.key) ?? _Prefs.debugMode.defaultValue;
  }

  @override
  Future<bool> setDebugMode(bool value) async {
    return preferences.setBool(_Prefs.debugMode.key, value);
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
