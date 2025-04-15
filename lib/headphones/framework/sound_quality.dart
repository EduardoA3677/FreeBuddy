import 'package:rxdart/rxdart.dart';

abstract class SoundQuality {
  ValueStream<SoundQualityMode> get soundQualityMode;

  Future<void> setSoundQualityMode(SoundQualityMode mode);
}

enum SoundQualityMode {
  connectivity,
  quality,
}
