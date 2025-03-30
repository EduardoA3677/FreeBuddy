import 'package:rxdart/rxdart.dart';

/// Framework interface for devices that support LDAC codec
abstract class Ldac {
  /// Whether LDAC codec is enabled
  ValueStream<bool> get ldacEnabled;
  
  /// Enable or disable LDAC codec
  Future<void> setLdacEnabled(bool enabled);
}