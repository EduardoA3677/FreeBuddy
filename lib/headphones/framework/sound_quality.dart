import 'package:rxdart/rxdart.dart';

/// Sound Quality Preference options
enum SoundQualityPreference {
  connectivity,
  quality;
}

/// Framework interface for devices that support adjustable sound quality
abstract class SoundQuality {
  /// Current sound quality preference
  ValueStream<SoundQualityPreference> get soundQuality;
  
  /// Available options for sound quality
  ValueStream<List<SoundQualityPreference>> get soundQualityOptions;
  
  /// Set the sound quality preference
  Future<void> setSoundQuality(SoundQualityPreference quality);
}