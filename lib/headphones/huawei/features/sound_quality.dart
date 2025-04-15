import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stream_channel/stream_channel.dart';

import '../../../logger.dart';
import '../../framework/sound_quality.dart';
import '../mbb.dart';
import 'base/feature_base.dart';
import 'settings.dart';

/// Implementation for Sound Quality functionality
class SoundQualityFeature extends MbbFeature implements SettingsFeature<HuaweiHeadphonesSettings> {
  static const featureId = 'soundQuality';

  final BehaviorSubject<SoundQualityMode> _soundQualityModeCtrl =
      BehaviorSubject<SoundQualityMode>();

  final BehaviorSubject<HuaweiHeadphonesSettings> _settingsCtrl =
      BehaviorSubject<HuaweiHeadphonesSettings>();

  /// Command to get current Sound Quality mode
  static final getSoundQualityCommand = MbbCommand(43, 163);

  /// Stream of current Sound Quality mode
  ValueStream<SoundQualityMode> get soundQualityMode => _soundQualityModeCtrl.stream;

  /// Creates command to set Sound Quality mode
  static MbbCommand setSoundQualityCommand(SoundQualityMode mode) {
    // mode.mbbCode == 0 for connectivity, 1 for quality
    // El segundo valor indica el modo activo: 0 para connectivity, 1 para quality
    return MbbCommand(43, 162, {
      1: [mode.mbbCode, mode == SoundQualityMode.quality ? 1 : 0]
    });
  }

  @override
  String get id => featureId;

  @override
  String get displayName => 'Sound Quality';

  @override
  bool isSupported(bool Function(String featureId) supportCheck) {
    return supportCheck(featureId);
  }

  @override
  void requestInitialData(StreamChannel<MbbCommand> mbb) {
    // Request current ANC mode
    mbb.sink.add(getSoundQualityCommand);
    AppLogger.log(LogLevel.debug, "Requested Sound Quality mode", tag: "MBB:$featureId");
  }

  @override
  bool handleMbbCommand(MbbCommand cmd) {
    if (!cmd.isAbout(getSoundQualityCommand) ||
        !cmd.args.containsKey(1) ||
        cmd.args[1]!.length < 2) {
      return false;
    }

    // El segundo byte contiene el código del modo actual
    // 0 para connectivity, 1 para quality
    final soundQualityCode = cmd.args[1]![1];

    // Convertir el código MBB al tipo SoundQualityMode
    final mode = SoundQualityMode.values.firstWhereOrNull((e) => e.mbbCode == soundQualityCode);

    if (mode != null) {
      AppLogger.log(LogLevel.debug, "Received Sound Quality mode: $mode (code: $soundQualityCode)",
          tag: "MBB:$featureId");
      _soundQualityModeCtrl.add(mode);
      return true;
    }

    AppLogger.log(LogLevel.warning, "Received invalid Sound Quality mode code: $soundQualityCode",
        tag: "MBB:$featureId");
    return false;
  }

  /// Set Sound Quality mode
  Future<void> setMode(SoundQualityMode mode, StreamChannel<MbbCommand> mbb) async {
    AppLogger.log(LogLevel.debug, "Setting Sound Quality mode to $mode (mbbCode: ${mode.mbbCode})",
        tag: "MBB:$featureId");

    // Enviar comando para cambiar el modo de calidad de sonido
    final command = setSoundQualityCommand(mode);
    mbb.sink.add(command);

    // Solicitar el estado actualizado después de aplicar el cambio
    // Esto nos permitirá confirmar que el cambio se aplicó correctamente
    await Future.delayed(const Duration(milliseconds: 500));
    mbb.sink.add(getSoundQualityCommand);
  }

  @override
  void dispose() {
    _soundQualityModeCtrl.close();
    _settingsCtrl.close();
    super.dispose();
  }

  /// Stream of current settings
  @override
  ValueStream<HuaweiHeadphonesSettings> get settings => _settingsCtrl.stream;

  /// Apply settings to device
  @override
  Future<void> applySettings(
      HuaweiHeadphonesSettings settings, StreamChannel<MbbCommand> mbb) async {
    if (settings.soundQuality != null) {
      await setMode(settings.soundQuality!, mbb);
    }
  }

  /// Update settings from MBB command
  @override
  HuaweiHeadphonesSettings? updateSettingsFromMbbCommand(
      MbbCommand cmd, HuaweiHeadphonesSettings currentSettings) {
    // Solo procesamos comandos relacionados con la calidad de sonido
    if (!cmd.isAbout(getSoundQualityCommand) ||
        !cmd.args.containsKey(1) ||
        cmd.args[1]!.length < 2) {
      return null;
    }

    final soundQualityCode = cmd.args[1]![1];
    final mode = SoundQualityMode.values.firstWhereOrNull((e) => e.mbbCode == soundQualityCode);

    // Si el modo es válido y es diferente al actual, actualizamos la configuración
    if (mode != null && mode != currentSettings.soundQuality) {
      AppLogger.log(LogLevel.debug, "Updating settings with Sound Quality mode: $mode",
          tag: "MBB:$featureId");
      return currentSettings.copyWith(soundQuality: mode);
    }

    return null;
  }
}

/// Extension to add MBB code conversion for SoundQualityMode enum
extension SoundQualityModeToMbbCode on SoundQualityMode {
  int get mbbCode => switch (this) {
        SoundQualityMode.connectivity => 0, // Prioriza conectividad
        SoundQualityMode.quality => 1, // Prioriza calidad de audio
      };
}
