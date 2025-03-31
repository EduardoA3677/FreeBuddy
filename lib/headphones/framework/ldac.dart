import 'package:rxdart/rxdart.dart';

/// Interface for headphones supporting LDAC audio codec
abstract interface class Ldac {
  /// Stream of LDAC status: true for Quality mode, false for Connectivity mode
  ValueStream<bool> get ldac;
  
  /// Set LDAC status: true for Quality mode, false for Connectivity mode
  Future<void> setLdac(bool enabled);
}