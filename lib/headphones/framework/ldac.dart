import 'package:rxdart/rxdart.dart';

abstract class Ldac {
  ValueStream<bool> get ldac;

  Future<void> setLdac(bool enabled);
}