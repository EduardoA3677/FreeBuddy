import 'package:rxdart/rxdart.dart';

/// Interface for headphones supporting LDAC audio codec
abstract interface class Ldac {
  ValueStream<bool> get ldacEnabled;
  
  ValueStream<LdacMode> get ldacMode;
  
  Future<void> setLdacEnabled(bool enabled);
  
  Future<void> setLdacMode(LdacMode mode);
}

/// LDAC (Lossy Digital Audio Compression) is a high-quality audio codec
/// developed by Sony that enables Bluetooth transmission of high-resolution audio
enum LdacMode {
  connectivity,  
  quality,
}