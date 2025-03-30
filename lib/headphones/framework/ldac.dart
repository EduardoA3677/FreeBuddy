import 'package:rxdart/rxdart.dart';

/// Framework interface for devices that support Low Latency mode
abstract class Ldac {
  /// Whether Low Latency mode is enabled
  ValueStream<bool> get ldacEnabled;
  
  /// Enable or disable Low Latency mode
  Future<void> setLdacEnabled(bool enabled);
}