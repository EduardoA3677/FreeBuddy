import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

// Enum for log levels
enum LogLevel { verbose, debug, info, warning, error, critical, fatal }

// Configuración mejorada para asegurar visibilidad en logcat
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: !Platform.isAndroid, // Desactivar colores para Android logcat
      printEmojis: false, // Los emojis pueden causar problemas en algunos logcat
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Usar formato de fecha recomendado
    ),
    level: Level.trace, // Usar el nivel más detallado
    output: MultiOutput([
      ConsoleOutput(),
      // Output personalizado que asegura visibilidad en logcat
      if (Platform.isAndroid) AndroidLogcatOutput(),
    ]),
  );
  static void log(LogLevel level, String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    final logMessage =
        "[${tag ?? 'FreeBuddy'}] $message"; // Enhanced Android logging for better logcat visibility
    if (Platform.isAndroid) {
      developer.log("FREEBUDDY_LOG: [$level] $logMessage", name: 'FreeBuddy', level: 1000);
      if (error != null) {
        developer.log("FREEBUDDY_ERROR: $error", name: 'FreeBuddy', error: error, level: 1000);
        if (stackTrace != null) {
          developer.log("FREEBUDDY_STACKTRACE: $stackTrace", name: 'FreeBuddy', level: 1000);
        }
      }
    }

    switch (level) {
      case LogLevel.verbose:
        _logger.t(logMessage);
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
        _logger.f(logMessage, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.fatal:
        developer.log(logMessage, level: 1000, error: error, stackTrace: stackTrace);
        break;
    }
  }

  static void setupGlobalErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      // Log in better format for Flutter errors
      final errorMsg =
          "FATAL EXCEPTION: ${details.context?.name ?? 'Flutter'}\n${details.exceptionAsString()}";
      log(LogLevel.error, errorMsg, error: details.exception, stackTrace: details.stack);

      // Make sure it also appears in system logs
      if (Platform.isAndroid) {
        developer.log("FREEBUDDY_FATAL: $errorMsg",
            name: 'FreeBuddy', error: details.exception, level: 2000);
      }
    };

    // Capture unhandled async errors
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      final errorMsg = "FATAL EXCEPTION: main\n${error.toString()}";
      log(LogLevel.critical, errorMsg, error: error, stackTrace: stack);

      // Make sure it also appears in system logs
      if (Platform.isAndroid) {
        developer.log("FREEBUDDY_FATAL: $errorMsg", name: 'FreeBuddy', error: error, level: 2000);
      }
      return true; // Indicates error has been handled
    };

    // Capture errors in async zones
    runZonedGuarded(() {
      // This function executes automatically in the captured zone
    }, (Object error, StackTrace stack) {
      final errorMsg = "FATAL EXCEPTION: ${Zone.current.toString()}\n${error.toString()}";
      log(LogLevel.fatal, errorMsg, error: error, stackTrace: stack);

      // Make sure it also appears in system logs
      if (Platform.isAndroid) {
        developer.log("FREEBUDDY_FATAL: $errorMsg", name: 'FreeBuddy', error: error, level: 2000);
      }
    });
  }
}

// Clase personalizada para asegurar que los logs aparezcan en Android logcat
class AndroidLogcatOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      // Usar developer.log en lugar de print
      developer.log("FREEBUDDY_LOGGER: $line", name: 'FreeBuddy');
    }
  }
}

// Clase para manejar múltiples outputs
class MultiOutput extends LogOutput {
  final List<LogOutput> outputs;

  MultiOutput(this.outputs);

  @override
  void output(OutputEvent event) {
    for (var output in outputs) {
      output.output(event);
    }
  }
}

// Helper function para simplificar el logging
void log(LogLevel level, String message, {String? tag, Object? error, StackTrace? stackTrace}) {
  AppLogger.log(level, message, tag: tag, error: error, stackTrace: stackTrace);
}

Logger get logg => AppLogger._logger;
Logger get loggI => AppLogger._logger;
