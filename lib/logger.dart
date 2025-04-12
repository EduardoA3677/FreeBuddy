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
      colors: true, // Desactivar colores para Android logcat
      printEmojis: true, // Los emojis pueden causar problemas en algunos logcat
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Usar formato de fecha recomendado
    ),
    level: Level.trace, // Usar el nivel más detallado
  );

  // Buffer para almacenar logs recientes
  static final List<String> _logBuffer = [];
  static const int _maxBufferSize =
      1000; // Reducido de 5000 a 1000 para evitar desbordamiento de memoria
  static LogLevel _bufferLogLevel =
      LogLevel.verbose; // Por defecto solo registrar info y superiores

  // Método para obtener el contenido actual de los logs
  static String getLogContent() {
    return _logBuffer.join('\n');
  }

  // Configura qué nivel de logs se guardan en el buffer
  static void setBufferLogLevel(LogLevel level) {
    _bufferLogLevel = level;
    log(LogLevel.debug, "Nivel de log en buffer cambiado a: $level");
  }

  // Limpiar el buffer de logs cuando sea necesario
  static void clearLogBuffer() {
    _logBuffer.clear();
    log(LogLevel.debug, "Buffer de logs limpiado");
  }

  // Método auxiliar para añadir una entrada al buffer de logs
  static void _addToBuffer(String entry, LogLevel level) {
    // Solo almacenar logs del nivel configurado o superior
    if (level.index < _bufferLogLevel.index) {
      return;
    }

    _logBuffer.add('[${DateTime.now().toIso8601String()}] $entry');
    // Mantener el buffer en un tamaño manejable
    if (_logBuffer.length > _maxBufferSize) {
      _logBuffer.removeAt(0);
    }
  }

  static void log(LogLevel level, String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    final logMessage =
        "[${tag ?? 'FreeBuddy'}] $message"; // Enhanced Android logging for better logcat visibility

    // Añadir al buffer interno para exportación
    final bufferEntry = "[$level] $logMessage";
    _addToBuffer(bufferEntry, level);

    if (error != null) {
      _addToBuffer("ERROR: $error", level);
      if (stackTrace != null) {
        // Limitar el tamaño del stacktrace para evitar consumo excesivo de memoria
        final limitedStackTrace = stackTrace.toString().split('\n').take(20).join('\n');
        _addToBuffer("STACKTRACE: $limitedStackTrace", level);
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

  // Método para exportar logs a un archivo
  static Future<void> exportLogsToFile(String filename) async {
    final logContent = getLogContent();
    final file = File(filename);
    await file.writeAsString(logContent);
    log(LogLevel.info, "Logs exportados exitosamente a $filename");
  }

  // Configuración de manejo global de errores
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

// Helper function para simplificar el logging
void log(LogLevel level, String message, {String? tag, Object? error, StackTrace? stackTrace}) {
  AppLogger.log(level, message, tag: tag, error: error, stackTrace: stackTrace);
}

Logger get logg => AppLogger._logger;
Logger get loggI => AppLogger._logger;
