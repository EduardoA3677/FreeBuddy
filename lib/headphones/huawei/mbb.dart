import 'dart:async';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:crclib/catalog.dart';
import 'package:stream_channel/stream_channel.dart';

import '../../logger.dart'; // Importación del logger

/// Helper class for Mbb protocol used to communicate with headphones
class MbbUtils {
  static int getLengthFromLengthByte(int lengthByte) => lengthByte + 3 + 2;

  static Uint8List checksum(List<int> data) {
    final crc = Crc16Xmodem().convert(data);
    final str = crc.toRadixString(16).padLeft(4, '0');
    final hexes = [str.substring(0, 2), str.substring(2)];
    final bytes = hexes.map((hex) => int.parse(hex, radix: 16));
    return Uint8List.fromList(bytes.toList());
  }

  static bool verifyChecksum(Uint8List payload) {
    final sum = checksum(payload.sublist(0, payload.length - 2));
    return sum[0] == payload[payload.length - 2] &&
        sum[1] == payload[payload.length - 1];
  }

  static void verifyIntegrity(Uint8List payload) {
    if (payload.length < 3 + 1 + 1 + 1 + 2) {
      throw Exception("Payload $payload is too short");
    }
    final magicBytes = (payload[0], payload[1], payload[3]);
    if (magicBytes != (90, 0, 0)) {
      throw Exception("Payload $payload has invalid magic bytes");
    }
    if (payload.length - 6 + 1 != payload[2]) {
      throw Exception("Length data from $payload doesn't match length byte");
    }
    if (!verifyChecksum(payload)) {
      throw Exception("Checksum from $payload doesn't match");
    }
  }
}

class MbbCommand {
  final int serviceId;
  final int commandId;
  final Map<int, List<int>> args;

  const MbbCommand(this.serviceId, this.commandId, [this.args = const {}]);

  bool isAbout(MbbCommand other) =>
      serviceId == other.serviceId && commandId == other.commandId;

  @override
  String toString() =>
      'MbbCommand(serviceId: $serviceId, commandId: $commandId, dataArgs: $args)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MbbCommand &&
          runtimeType == other.runtimeType &&
          serviceId == other.serviceId &&
          commandId == other.commandId &&
          const MapEquality().equals(args, other.args);

  @override
  int get hashCode => serviceId.hashCode ^ commandId.hashCode ^ args.hashCode;
  Uint8List toPayload() {
    final data = <int>[];
    args.forEach((key, value) {
      data.add(key);
      data.add(value.length);
      data.addAll(value);
    });
    final dataBytes = Uint8List.fromList(data);
    final byteLength =
        dataBytes.length + 2 + 1; // +2->checksums +1->magic bytes
    assert(byteLength <= 255);
    final bytesList = [
      90, // Magic bytes
      0, // Additional magic byte
      byteLength,
      0, // Another magic byte (I think)
      serviceId,
      commandId,
      ...dataBytes,
    ];
    try {
      final functionType = _identifyFunctionType(serviceId, commandId);
      logg.i(
          '【$functionType】MBB Command preparing to send: serviceId=$serviceId, commandId=$commandId, args=${_formatArgs(args)}');
    } catch (e) {
      logg.e('Error logging MBB command', error: e);
    }

    return Uint8List.fromList(bytesList..addAll(MbbUtils.checksum(bytesList)));
  }

  static List<MbbCommand> fromPayload(
    Uint8List payload, {
    bool verify = true,
    bool smartDivide = true,
  }) {
    final divided = <Uint8List>[];
    if (smartDivide) {
      while (payload.length >= 8) {
        divided.add(
            payload.sublist(0, MbbUtils.getLengthFromLengthByte(payload[2])));
        payload = payload.sublist(MbbUtils.getLengthFromLengthByte(payload[2]));
      }
    } else {
      divided.add(payload);
    }

    if (divided.isEmpty) {
      if (verify) {
        throw Exception("No commands found in $payload");
      } else {
        return [];
      }
    }

    final cmds = <MbbCommand>[];
    for (final divPay in divided) {
      if (verify) MbbUtils.verifyIntegrity(divPay);
      final serviceId = divPay[4];
      final commandId = divPay[5];
      final dataBytes = divPay.sublist(6, divPay.length - 2);

      final args = <int, List<int>>{};
      var offset = 0;
      while (offset < dataBytes.length) {
        final argId = dataBytes[offset];
        final argLength = dataBytes[offset + 1];
        final argData = dataBytes.sublist(offset + 2, offset + 2 + argLength);
        offset += 2 + argLength;
        args[argId] = argData;
      }
      final cmd = MbbCommand(serviceId, commandId, args);
      try {
        final functionType = _identifyFunctionType(serviceId, commandId);
        logg.i(
            '【$functionType】MBB Command RECEIVED: serviceId=$serviceId, commandId=$commandId, args=${_formatArgs(args)}');
      } catch (e) {
        logg.e('Error logging MBB received command', error: e);
      }

      cmds.add(cmd);
    }
    return cmds;
  }
}

/// Identifica el tipo de función basada en serviceId y commandId
String _identifyFunctionType(int serviceId, int commandId) {
  // Service ID 43: Gestos y funciones principales
  if (serviceId == 43) {
    if (commandId == 13 || commandId == 14) {
      return "BATTERY";
    } else if (commandId == 21 || commandId == 20) {
      return "DOUBLE_TAP";
    } else if (commandId == 22 || commandId == 23) {
      return "HOLD";
    } else if (commandId == 24 || commandId == 25) {
      return "HOLD_MODES";
    } else if (commandId == 170 || commandId == 171 || commandId == 172) {
      return "ANC";
    } else if (commandId == 180 || commandId == 181) {
      return "AUTO_PAUSE";
    } else if (commandId == 190 || commandId == 191) {
      return "IN_EAR";
    }
    return "CONTROL";
  }
  // Service ID 10: Sistema y batería
  else if (serviceId == 10) {
    if (commandId == 12 || commandId == 13) {
      return "BATTERY";
    }
    return "SYSTEM";
  }
  // Service ID 11: Actualización de firmware
  else if (serviceId == 11) {
    return "FIRMWARE";
  }
  return "OTHER";
}

/// Da formato a los argumentos para hacerlos más legibles
String _formatArgs(Map<int, List<int>> args) {
  if (args.isEmpty) return "{}";

  final buffer = StringBuffer("{");
  var first = true;

  args.forEach((key, value) {
    if (!first) buffer.write(", ");
    first = false;

    buffer.write("$key: ");

    if (value.length == 1) {
      // Para valores simples, mostrar el valor directamente
      buffer.write("[${value[0]}]");
    } else if (value.length <= 4) {
      // Para valores pequeños, mostrar la lista completa
      buffer.write("$value");
    } else {
      // Para listas largas, mostrar longitud y algunos elementos
      buffer.write("[len:${value.length}][${value.take(3).join(',')}...]");
    }
  });

  buffer.write("}");
  return buffer.toString();
}

StreamChannel<MbbCommand> mbbChannel(StreamChannel<Uint8List> rfcomm) =>
    rfcomm.transform(
      StreamChannelTransformer(
        StreamTransformer.fromHandlers(handleData: (data, stream) {
          try {
            logg.d('MBB RAW DATA RECEIVED: ${data.length} bytes');
            final commands = MbbCommand.fromPayload(data);
            for (final cmd in commands) {
              if (cmd.serviceId == 10 && cmd.commandId == 13) continue;
              try {
                final functionType =
                    _identifyFunctionType(cmd.serviceId, cmd.commandId);
                logg.d(
                    '【$functionType】MBB Processing: serviceId=${cmd.serviceId}, '
                    'commandId=${cmd.commandId}, args=${_formatArgs(cmd.args)}');
              } catch (logError) {
                logg.e('Error processing command args', error: logError);
              }
              stream.add(cmd);
            }
          } catch (e, stacktrace) {
            logg.e('Error processing MBB payload',
                error: e, stackTrace: stacktrace);
          }
        }, handleDone: (stream) {
          try {
            logg.d('MBB stream finalizado');
            stream.close();
          } catch (e) {
            logg.e('Error closing MBB stream', error: e);
          }
        }, handleError: (error, stackTrace, stream) {
          try {
            logg.e('MBB stream error', error: error, stackTrace: stackTrace);
            stream.addError(error, stackTrace);
          } catch (e) {
            logg.e('Error propagating MBB stream error', error: e);
          }
        }),
        StreamSinkTransformer.fromHandlers(
          handleData: (data, sink) {
            try {
              final payload = data.toPayload();
              logg.d('MBB RAW DATA SENT: ${payload.length} bytes');
              rfcomm.sink.add(payload);
            } catch (e, stacktrace) {
              logg.e('Error sending MBB command',
                  error: e, stackTrace: stacktrace);
            }
          },
          handleError: (error, stackTrace, sink) {
            try {
              logg.e('MBB sink error', error: error, stackTrace: stackTrace);
              sink.addError(error, stackTrace);
            } catch (e) {
              logg.e('Error propagating MBB sink error', error: e);
            }
          },
        ),
      ),
    );
