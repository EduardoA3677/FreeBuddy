import 'package:rxdart/rxdart.dart';

import '../framework/sound_quality.dart';

/// Mixin for adding sound quality functionality to simulators
mixin SoundQualitySim implements SoundQuality {
  final _soundQualityModeCtrl =
      BehaviorSubject<SoundQualityMode>.seeded(SoundQualityMode.connectivity);

  @override
  ValueStream<SoundQualityMode> get soundQualityMode => _soundQualityModeCtrl.stream;

  @override
  Future<void> setSoundQualityMode(SoundQualityMode mode) async {
    _soundQualityModeCtrl.add(mode);
  }

  /// Dispose of resources
  void disposeSoundQuality() {
    _soundQualityModeCtrl.close();
  }
}

/// Placeholder mixin for simulators that don't need to implement sound quality functionality
mixin SoundQualitySimPlaceholder implements SoundQuality {
  @override
  ValueStream<SoundQualityMode> get soundQualityMode => BehaviorSubject();

  @override
  Future<void> setSoundQualityMode(SoundQualityMode mode) async {}
}
