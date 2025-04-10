import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

// Enum for log levels
enum LogLevel { verbose, debug, info, warning, error, critical, fatal }

// Updated to use Level.trace and Level.fatal instead of deprecated levels
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 2),
    level: Level.trace, // Replaced Level.verbose with Level.trace
  );

  static void log(LogLevel level, String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    final logMessage = "[${tag ?? 'General'}] $message";
    switch (level) {
      case LogLevel.verbose:
        _logger.t(logMessage); // Replaced _logger.v with _logger.t
        break;
      case LogLevel.debug:
        _logger.d(logMessage);
        break;
      case LogLevel.info:
        _logger.i(logMessage);
        break;
      case LogLevel.warning:
        _logger.w(logMessage, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.error:
        _logger.e(logMessage, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.critical:
        _logger.f(logMessage,
            error: error, stackTrace: stackTrace); // Replaced _logger.wtf with _logger.f
        break;
      case LogLevel.fatal:
        developer.log(logMessage, level: 1000, error: error, stackTrace: stackTrace);
        break;
    }
  }

  static void setupGlobalErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      log(LogLevel.error, "Flutter Error: ${details.exceptionAsString()}",
          error: details.exception, stackTrace: details.stack);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      log(LogLevel.fatal, "Uncaught Platform Error", error: error, stackTrace: stack);
      return true;
    };

    runZonedGuarded(() {
      // App entry point
    }, (error, stack) {
      log(LogLevel.fatal, "Uncaught Zone Error", error: error, stackTrace: stack);
    });
  }
}

void log(LogLevel level, String message, {String? tag, Object? error, StackTrace? stackTrace}) {
  AppLogger.log(level, message, tag: tag, error: error, stackTrace: stackTrace);
}

// Backward compatibility
Logger get logg => AppLogger._logger;
Logger get loggI => AppLogger._logger;
