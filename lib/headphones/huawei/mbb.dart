import 'dart:async';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:crclib/catalog.dart';
import 'package:logger/logger.dart';
import 'package:stream_channel/stream_channel.dart';

import '../../logger.dart';

// Logger específico para el protocolo MBB
final _mbbLogger = logg;

/// Helper class for Mbb protocol used to communicate with headphones
class MbbUtils {
  // plus 3 magic bytes + 2 command bytes
  static int getLengthFromLengthByte(int lengthByte) => lengthByte + 3 + 2;

  /// Get Crc16Xmodem checksum of [data] as Uin8List of two bytes
  static Uint8List checksum(List<int> data) {
    final crc = Crc16Xmodem().convert(
        data); // NOTA: Hubo un error aquí donde crc no añadía padding de ceros,
    // lo que causaba rechazo de mensajes y problemas con los gestos.
    // Importante: necesitamos tests unitarios para esta funcionalidad
    final str = crc.toRadixString(16).padLeft(4, '0');
    final hexes = [str.substring(0, 2), str.substring(2)];
    final bytes = hexes.map((hex) => int.parse(hex, radix: 16));
    return Uint8List.fromList(bytes.toList());
  }

  /// Checks if checksums are alright
  static bool verifyChecksum(Uint8List payload) {
    final sum = checksum(payload.sublist(0, payload.length - 2));
    return sum[0] == payload[payload.length - 2] &&
        sum[1] == payload[payload.length - 1];
  }

  /// Will return exception if anything wrong. Otherwise does nothing.
  static void verifyIntegrity(Uint8List payload) {
    // 3 magic bytes, 1 length, 1 service, 1 command, 2 checksum
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

/// Helper class to contain info about single command
/// Also parses it and generates payload
class MbbCommand {
  final int serviceId;
  final int commandId;
  final Map<int, List<int>> args;

  const MbbCommand(this.serviceId, this.commandId, [this.args = const {}]);

  /// Is the command *about* the same thing as [other]? Not necessary same args
  ///
  /// Compares serviceId and commandId
  bool isAbout(MbbCommand other) =>
      serviceId == other.serviceId && commandId == other.commandId;

  @override
  String toString() => 'MbbCommand(serviceId: $serviceId, '
      'commandId: $commandId, dataArgs: $args)';

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

  /// Convert to binary data to be sent to headphones
  Uint8List toPayload() {
    final data = <int>[];
    args.forEach((key, value) {
      data.add(key);
      data.add(value.length);
      data.addAll(value);
    });
    final dataBytes = Uint8List.fromList(data);
    final byteLength = dataBytes.length + 2 + 1; // +2->checksums +1->*because*
    assert(byteLength <= 255);
    final bytesList = [
      90, // Magic bytes
      0, //
      byteLength,
      0, // another magic byte (i think)
      serviceId,
      commandId,
      ...dataBytes, // Make sure they are >0 and <256
    ]; // Log detallado del comando enviado
    _mbbLogger.context('MBB',
        '📤 Enviando comando: serviceId=$serviceId, commandId=$commandId',
        level: Level.info);
    _mbbLogger.context(
        'MBB', 'Argumentos del comando: ${LogHelper.formatObject(args)}',
        level: Level.debug);

    final payload =
        Uint8List.fromList(bytesList..addAll(MbbUtils.checksum(bytesList)));
    _mbbLogger.binary('Payload del comando', payload);

    return payload;
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
      final cmd = MbbCommand(
          serviceId, commandId, args); // Log detallado del comando recibido
      _mbbLogger.context('MBB',
          '📥 Comando recibido: serviceId=$serviceId, commandId=$commandId',
          level: Level.info);

      if (LogConfig.verboseMode) {
        final argsDetails = args
            .map((key, value) => MapEntry(key, LogHelper.formatBytes(value)));
        _mbbLogger.context('MBB', 'Argumentos detallados: $argsDetails',
            level: Level.debug);
      }

      cmds.add(cmd);
    }
    return cmds;
  }
}

StreamChannel<MbbCommand> mbbChannel(StreamChannel<Uint8List> rfcomm) =>
    rfcomm.transform(
      StreamChannelTransformer(
        StreamTransformer.fromHandlers(
          handleData: (data, stream) {
            _mbbLogger.context(
                'MBB', '📥 Datos binarios recibidos: ${data.length} bytes',
                level: Level.debug);

            // Log detallado de los datos brutos si estamos en modo verbose
            if (LogConfig.verboseMode) {
              _mbbLogger.binary('Datos brutos recibidos', data);
            }

            try {
              final commands = MbbCommand.fromPayload(data);
              for (final cmd in commands) {
                // Filtrar comandos específicos que no necesitamos procesar
                if (cmd.serviceId == 10 && cmd.commandId == 13) {
                  _mbbLogger.context('MBB',
                      'Filtrando comando de tipo: serviceId=${cmd.serviceId}, commandId=${cmd.commandId}',
                      level: Level.debug);
                  continue;
                }

                // Log detallado del comando que estamos procesando
                if (LogConfig.verboseMode) {
                  final argsDetails = cmd.args.map((key, value) => MapEntry(key,
                      '(len:${value.length}) ${LogHelper.formatBytes(value)}'));
                  _mbbLogger.context(
                      'MBB',
                      'Procesando comando: serviceId=${cmd.serviceId}, '
                          'commandId=${cmd.commandId}, argsDetails=$argsDetails',
                      level: Level.debug);
                }

                stream.add(cmd);
              }
            } catch (e, stacktrace) {
              _mbbLogger.context('MBB', '❌ Error al procesar datos MBB',
                  level: Level.error, error: e, stackTrace: stacktrace);

              // Log detallado del payload problemático
              _mbbLogger.binary('Payload con error', data);
            }
          },
        ),
        StreamSinkTransformer.fromHandlers(
          handleData: (data, sink) {
            try {
              final payload = data.toPayload();
              _mbbLogger.context(
                  'MBB', '📤 Enviando datos: ${payload.length} bytes',
                  level: Level.debug);

              // Log detallado en modo verbose
              if (LogConfig.verboseMode) {
                _mbbLogger.binary('Enviando payload', payload);
              }

              rfcomm.sink.add(payload);
            } catch (e, stacktrace) {
              _mbbLogger.context('MBB', '❌ Error al enviar comando MBB',
                  level: Level.error, error: e, stackTrace: stacktrace);

              // Log de información del comando que falló
              _mbbLogger.context('MBB',
                  'Comando fallido: serviceId=${data.serviceId}, commandId=${data.commandId}',
                  level: Level.debug);
              if (data.args.isNotEmpty) {
                _mbbLogger.context('MBB',
                    'Args del comando fallido: ${LogHelper.formatObject(data.args)}',
                    level: Level.debug);
              }
            }
          },
        ),
      ),
    );
