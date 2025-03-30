import 'package:rxdart/rxdart.dart';

/// Framework interface for devices that support Low Latency mode
abstract class LowLatency {
  /// Whether Low Latency mode is enabled
  ValueStream<bool> get lowLatencyEnabled;
  
  /// Enable or disable Low Latency mode
  Future<void> setLowLatencyEnabled(bool enabled);
}