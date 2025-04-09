import 'dart:isolate';

import 'package:logger/logger.dart';

final _prettyLogger = Logger(
  filter: ProductionFilter(),
  printer: FunctionAwarePrinter(),
  level: Level.all,
);

final _isolateLogger = Logger(
  filter: ProductionFilter(),
  printer: FunctionAwareIsolatePrinter(),
  level: Level.all,
);

Logger get logg => _prettyLogger;
Logger get loggI => _isolateLogger;

/// Base printer that shows the calling function/method name in logs
class FunctionAwarePrinter extends PrettyPrinter {
  FunctionAwarePrinter({
    int super.methodCount = 0,
    int super.errorMethodCount = 8,
    super.lineLength = 100,
    super.colors = true,
    super.printEmojis = true,
    bool super.printTime = true,
  });
  @override
  List<String> log(LogEvent event) {
    // Extract calling function info from stack trace
    final functionInfo =
        _extractCallerInfo(event.stackTrace ?? StackTrace.current);

    // Add function info to message in a cleaner format
    String enhancedMessage = event.message;

    // If message doesn't already have a function indicator (like the ones we added with 【TYPE】)
    if (!enhancedMessage.contains('】')) {
      enhancedMessage =
          "「${functionInfo.fileName}:${functionInfo.function}」 $enhancedMessage";
    } else {
      // For messages that already have a function type indicator, add the caller info at the end
      enhancedMessage =
          "$enhancedMessage 「${functionInfo.fileName}:${functionInfo.function}」";
    }

    return super.log(LogEvent(
      event.level,
      enhancedMessage,
      time: event.time,
      error: event.error,
      stackTrace: event.stackTrace,
    ));
  }

  /// Extract caller information from stack trace
  _CallerInfo _extractCallerInfo(StackTrace stackTrace) {
    final frames = stackTrace.toString().split('\n');

    // Skip logger frames to find actual caller
    // Usually frame 3 or 4 is the actual caller (after logger internal calls)
    String callerFrame = '';
    for (int i = 0; i < frames.length; i++) {
      final frame = frames[i];
      // Skip logger internal frames
      if (frame.contains('logger.dart') && i + 1 < frames.length) {
        continue;
      }
      // Found the first non-logger frame
      if (!frame.contains('logger.dart')) {
        callerFrame = frame;
        break;
      }
    }

    // Parse the frame to extract file and function information
    final fileInfo = _extractFileInfo(callerFrame);
    final functionName = _extractFunctionName(callerFrame);

    return _CallerInfo(fileInfo, functionName);
  }

  String _extractFileInfo(String frame) {
    // Frame format typically: "#1      _MyHomePageState.build (package:my_app/main.dart:61:13)"
    final filePathMatch = RegExp(r'\((.+?):[0-9]+:[0-9]+\)').firstMatch(frame);
    if (filePathMatch != null && filePathMatch.groupCount >= 1) {
      final fullPath = filePathMatch.group(1) ?? 'unknown';
      // Get just the filename without the path
      final fileName = fullPath.split('/').last;
      return fileName;
    }
    return 'unknown';
  }

  String _extractFunctionName(String frame) {
    // Extract method/function name
    final methodMatch =
        RegExp(r'[A-Za-z0-9_]+\.[A-Za-z0-9_]+').firstMatch(frame);
    if (methodMatch != null) {
      return methodMatch.group(0) ?? 'unknown';
    }
    return 'unknown';
  }
}

/// Isolate-aware printer that also shows the calling function name
class FunctionAwareIsolatePrinter extends FunctionAwarePrinter {
  @override
  List<String> log(LogEvent event) {
    final isolateInfo =
        "<Isolate '${Isolate.current.debugName}' (${Isolate.current.hashCode})>";

    // Extract calling function info
    final functionInfo =
        _extractCallerInfo(event.stackTrace ?? StackTrace.current);

    // Add both isolate and function info to message
    final enhancedMessage =
        "$isolateInfo [${functionInfo.fileName}:${functionInfo.function}] ${event.message}";

    return super.log(LogEvent(
      event.level,
      enhancedMessage,
      time: event.time,
      error: event.error,
      stackTrace: event.stackTrace,
    ));
  }
}

/// Helper class to store caller information
class _CallerInfo {
  final String fileName;
  final String function;

  _CallerInfo(this.fileName, this.function);
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
