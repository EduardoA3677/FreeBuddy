/// Define the Level class for compatibility with the logger package
/// This provides a local definition to avoid import conflicts
class Level {
  final String name;
  final int value;

  const Level(this.name, this.value);

  static const Level verbose = Level('VERBOSE', 0);
  static const Level trace = Level('TRACE', 0);
  static const Level debug = Level('DEBUG', 1);
  static const Level info = Level('INFO', 2);
  static const Level warning = Level('WARNING', 3);
  static const Level error = Level('ERROR', 4);
  static const Level fatal = Level('FATAL', 5);
  static const Level nothing = Level('NOTHING', 6);

  @override
  String toString() => name;
}
