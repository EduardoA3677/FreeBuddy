import 'dart:isolate';

import 'package:logger/logger.dart';

final _prettyLogger = Logger(
  filter: ProductionFilter(),
  printer: PrettyPrinter(),
  level: Level.all,
);

final _isolateLogger = Logger(
  filter: ProductionFilter(),
  printer: TheLastIsolatePrinter(),
  level: Level.all,
);

Logger get logg => _prettyLogger;
Logger get loggI => _isolateLogger;

class TheLastIsolatePrinter extends PrettyPrinter {
  @override
  List<String> log(LogEvent event) {
    final message =
        "<Isolate '${Isolate.current.debugName}' (${Isolate.current.hashCode})>\n${event.message}";
    return super.log(LogEvent(
      event.level,
      message,
      time: event.time,
      error: event.error,
      stackTrace: event.stackTrace,
    ));
  }
}

extension Errors on Logger {
  /// Quick drop-in for Stream's onError with improved error context
  void onError(Object m, StackTrace s) {
    e(m, stackTrace: s);
  }

  /// Log an error with enhanced context
  void logError(String message, {Object? error, StackTrace? stackTrace}) {
    e(message, error: error, stackTrace: stackTrace);
  }
}
