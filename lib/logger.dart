import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Nivel de log global que se puede cambiar en tiempo de ejecución
/// para controlar la verbosidad de los logs
Level _currentLogLevel = kDebugMode ? Level.debug : Level.warning;

/// Personalización del formato de los logs para mayor claridad
final _customPrinter = PrettyPrinter(
  methodCount: 1,
  errorMethodCount: 8,
  lineLength: 120,
  colors: true,
  printEmojis: true,
  dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
);

/// Logger principal para uso general en la aplicación
final _prettyLogger = Logger(
  filter: DevelopmentFilter(),
  printer: _customPrinter,
  level: _currentLogLevel,
  output: ConsoleOutput(),
);

/// Logger específico para uso en isolates
final _isolateLogger = Logger(
  filter: DevelopmentFilter(),
  printer: TheLastIsolatePrinter(),
  level: _currentLogLevel,
  output: ConsoleOutput(),
);

/// Acceso al logger principal
Logger get logg => _prettyLogger;

/// Acceso al logger para isolates
Logger get loggI => _isolateLogger;

/// Actualiza el nivel de log global
void setLogLevel(Level level) {
  _currentLogLevel = level;
  Logger.level =
      level; // Using the static property instead of instance property
}

/// Formateador mejorado para logs en isolates con identificación clara
class TheLastIsolatePrinter extends PrettyPrinter {
  TheLastIsolatePrinter({
    int super.methodCount = 1,
    int super.errorMethodCount = 8,
    super.lineLength = 120,
    super.colors = true,
    super.printEmojis = true,
    super.dateTimeFormat = DateTimeFormat.onlyTimeAndSinceStart,
  });

  @override
  List<String> log(LogEvent event) {
    final isolateName = Isolate.current.debugName ?? 'unnamed';
    final isolateId = Isolate.current.hashCode;

    return super.log(
      LogEvent(
        event.level,
        "⚡ [Isolate '$isolateName' (#$isolateId)]\n${event.message}",
        time: event.time,
        error: event.error,
        stackTrace: event.stackTrace,
      ),
    );
  }
}

/// Extensiones para facilitar el logueo de errores y tipos específicos de datos
extension LoggerExtensions on Logger {
  /// Quick drop-in for Stream's onError
  void onError(Object m, StackTrace s) => e(m, stackTrace: s);

  /// Log con contexto para agrupar logs relacionados
  void context(String context, String message,
      {Level level = Level.info, Object? error, StackTrace? stackTrace}) {
    final contextMsg = "[$context] $message";
    switch (level) {
      case Level.trace:
        t(contextMsg, error: error, stackTrace: stackTrace);
        break;
      case Level.debug:
        d(contextMsg, error: error, stackTrace: stackTrace);
        break;
      case Level.info:
        i(contextMsg, error: error, stackTrace: stackTrace);
        break;
      case Level.warning:
        w(contextMsg, error: error, stackTrace: stackTrace);
        break;
      case Level.error:
        e(contextMsg, error: error, stackTrace: stackTrace);
        break;
      case Level.fatal:
        f(contextMsg, error: error, stackTrace: stackTrace);
        break;
      default:
        i(contextMsg, error: error, stackTrace: stackTrace);
    }
  }

  /// Log datos binarios con formato legible
  void binary(String message, List<int> data, {int maxBytes = 100}) {
    final hexList = data
        .take(maxBytes)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .toList();
    final hexString = hexList.join(' ');
    final printable = data
        .take(maxBytes)
        .map((b) => b >= 32 && b <= 126 ? String.fromCharCode(b) : '.')
        .join();

    d('$message\nHEX: $hexString\nASCII: $printable${data.length > maxBytes ? " (${data.length - maxBytes} more bytes...)" : ""}');
  }

  /// Log objetos JSON con formato legible
  void json(String message, dynamic jsonData) {
    try {
      final encoder = JsonEncoder.withIndent('  ');
      final jsonString = encoder.convert(jsonData);
      d('$message\n$jsonString');
    } catch (exception) {
      // Using e() method for error logging with a different variable name to avoid conflicts
      e('Error al formatear JSON', error: exception);
      d('$message\n$jsonData');
    }
  }
}

/// Configuración para entornos de ejecución
class LogConfig {
  /// Si está en modo desarrollo
  static bool get isDevelopment => kDebugMode;

  /// Si se debe mostrar información detallada
  static bool _verboseMode = false;

  /// Habilita o deshabilita el modo verbose
  static set verboseMode(bool value) {
    _verboseMode = value;
    setLogLevel(_verboseMode
        ? Level.debug
        : (isDevelopment ? Level.info : Level.warning));
  }

  /// Retorna si está en modo verbose
  static bool get verboseMode => _verboseMode;
}

/// Funciones de ayuda para facilitar el logging
class LogHelper {
  /// Formatea una lista de bytes para mostrarla de manera legible
  static String formatBytes(List<int> bytes, {int maxLength = 100}) {
    if (bytes.isEmpty) return '(empty)';

    final visibleBytes = bytes.take(maxLength).toList();
    final hexValues = visibleBytes
        .map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}')
        .join(' ');

    if (bytes.length > maxLength) {
      return '$hexValues... (${bytes.length - maxLength} more bytes)';
    }
    return hexValues;
  }

  /// Formatea un objeto para mostrar en los logs
  static String formatObject(dynamic obj) {
    if (obj == null) return 'null';
    if (obj is List) {
      if (obj is List<int> && obj.every((e) => e >= 0 && e <= 255)) {
        return 'Bytes[${obj.length}]: ${formatBytes(obj)}';
      }
      return 'List[${obj.length}]: ${obj.take(10).join(', ')}${obj.length > 10 ? '...' : ''}';
    }
    if (obj is Map) {
      final entries = obj.entries
          .take(5)
          .map((e) => '${e.key}: ${formatObjectCompact(e.value)}')
          .join(', ');
      return 'Map{${obj.length > 5 ? '$entries...' : entries}}';
    }
    return obj.toString();
  }

  /// Versión compacta del formateo de objetos
  static String formatObjectCompact(dynamic obj) {
    if (obj == null) return 'null';
    if (obj is List) return 'List[${obj.length}]';
    if (obj is Map) return 'Map{${obj.length}}';
    if (obj is String && obj.length > 20) return '${obj.substring(0, 17)}...';
    return obj.toString();
  }
}

/// Alias corto para ahorrar código al escribir logs
final log = logg;

/// Crea un mensaje de log con contexto Bluetooth
void logBt(String message,
    {Level level = Level.info, Object? error, StackTrace? stackTrace}) {
  logg.context('Bluetooth', message,
      level: level, error: error, stackTrace: stackTrace);
}

/// Crea un mensaje de log con contexto Headphones
void logHeadphones(String message,
    {Level level = Level.info, Object? error, StackTrace? stackTrace}) {
  logg.context('Headphones', message,
      level: level, error: error, stackTrace: stackTrace);
}

/// Crea un mensaje de log con contexto UI
void logUi(String message,
    {Level level = Level.info, Object? error, StackTrace? stackTrace}) {
  logg.context('UI', message,
      level: level, error: error, stackTrace: stackTrace);
}
