import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

// Enum for log levels
enum LogLevel { verbose, debug, info, warning, error, critical, fatal }

// Configuración mejorada para asegurar visibilidad en logcat
// Nueva clase para manejar la lógica del buffer de logs.
class LogBuffer {
  static const int _defaultMaxSize = 1000;
  final List<String> _entries = [];
  LogLevel bufferLogLevel;
  final int maxSize;

  LogBuffer({this.bufferLogLevel = LogLevel.verbose, this.maxSize = _defaultMaxSize});

  void add(LogLevel level, String message, {Object? error, StackTrace? stackTrace}) {
    if (!_shouldBuffer(level)) return;

    final entry = "[${DateTime.now().toIso8601String()}] [$level] $message";
    _entries.add(entry);

    if (error != null) {
      _entries.add("ERROR: $error");
      if (stackTrace != null) {
        _entries.add("STACKTRACE: ${_limitStackTrace(stackTrace)}");
      }
    }

    _ensureSizeLimit();
  }

  String get content => _entries.join('\n');

  void clear() => _entries.clear();

  bool _shouldBuffer(LogLevel level) => level.index >= bufferLogLevel.index;

  void _ensureSizeLimit() {
    while (_entries.length > maxSize) {
      _entries.removeAt(0);
    }
  }

  String _limitStackTrace(StackTrace stackTrace, {int maxLines = 20}) {
    return stackTrace.toString().split('\n').take(maxLines).join('\n');
  }
}

// Clase AppLogger mejor organizada
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: Level.trace,
  );

  static final LogBuffer _logBuffer = LogBuffer();

  static void log(LogLevel level, String message,
      {String? tag = 'FreeBuddy', Object? error, StackTrace? stackTrace}) {
    final formattedMessage = _formatMessage(tag, message);
    _logBuffer.add(level, formattedMessage, error: error, stackTrace: stackTrace);

    switch (level) {
      case LogLevel.verbose:
        _logger.t(formattedMessage);
        break;
      case LogLevel.debug:
        _logger.d(formattedMessage);
        break;
      case LogLevel.info:
        _logger.i(formattedMessage);
        break;
      case LogLevel.warning:
        _logger.w(formattedMessage, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.error:
        _logger.e(formattedMessage, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.critical:
        _logger.f(formattedMessage, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.fatal:
        developer.log(formattedMessage, level: 1000, error: error, stackTrace: stackTrace);
        break;
    }
  }

  static String _formatMessage(String? tag, String message) {
    return "[$tag] $message";
  }

  static Future<void> exportLogsToFile(String filename) async {
    final file = File(filename);
    await file.writeAsString(_logBuffer.content);
    log(LogLevel.info, "Logs exportados exitosamente a $filename");
  }

  static void setBufferLogLevel(LogLevel level) {
    _logBuffer.bufferLogLevel = level;
    log(LogLevel.debug, "Nivel de log en buffer cambiado a: $level");
  }

  static void clearLogBuffer() {
    _logBuffer.clear();
    log(LogLevel.debug, "Buffer de logs limpiado");
  }

  static String getLogContent() => _logBuffer.content; // ⬅️✨ Aquí está tu nuevo método.

  static void setupGlobalErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final errorMsg =
          "FATAL EXCEPTION: ${details.context?.name ?? 'Flutter'}\n${details.exceptionAsString()}";
      log(LogLevel.error, errorMsg, error: details.exception, stackTrace: details.stack);
      _logAndroidFatalError(errorMsg, details.exception);
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      final errorMsg = "FATAL EXCEPTION: main\n${error.toString()}";
      log(LogLevel.critical, errorMsg, error: error, stackTrace: stack);
      _logAndroidFatalError(errorMsg, error);
      return true;
    };

    runZonedGuarded(() {}, (Object error, StackTrace stack) {
      final errorMsg = "FATAL EXCEPTION: ${Zone.current}\n${error.toString()}";
      log(LogLevel.fatal, errorMsg, error: error, stackTrace: stack);
      _logAndroidFatalError(errorMsg, error);
    });
  }

  static void _logAndroidFatalError(String message, Object error) {
    if (Platform.isAndroid) {
      developer.log("FREEBUDDY_FATAL: $message", name: 'FreeBuddy', error: error, level: 2000);
    }
  }
}
