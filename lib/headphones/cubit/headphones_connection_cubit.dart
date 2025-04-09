import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:the_last_bluetooth/the_last_bluetooth.dart';

import '../../logger.dart';
import 'headphones_cubit_objects.dart';
import 'model_matching.dart';

class HeadphonesConnectionCubit extends Cubit<HeadphonesConnectionState> {
  final TheLastBluetooth _bluetooth;
  StreamChannel<Uint8List>? _connection;
  StreamSubscription? _btEnabledStream;
  StreamSubscription? _devStream;
  final Map<BluetoothDevice, StreamSubscription> _watchedKnownDevices = {};
  static const connectTries = 3;
  static const killOtherCubitTimeout = Duration(seconds: 3);
  static const _killUrself = "kill urself";

  /// indicating all "killing other cubits" is done and we can call _init()
  bool _warCrimesFinished = false;

  // Add a flag to track if the cubit is closed
  bool _isClosed = false;

  static const pingReceivePortName = 'pingHeadphonesCubitPort';
  final _pingReceivePort = ReceivePort('dummyHeadphonesCubitPort');
  late final StreamSubscription _pingReceivePortSS;

  /// returns true if no port, and false if timeout
  static Future<bool> _checkUntilNoPort(Duration timeout) async {
    noPort() =>
        IsolateNameServer.lookupPortByName(
            HeadphonesConnectionCubit.pingReceivePortName) ==
        null;
    if (noPort()) return true;
    return await Stream.periodic(
      Duration(milliseconds: 50),
      (_) => noPort(),
    ).firstWhere((e) => e).timeout(timeout, onTimeout: () => false);
  }

  static Future<bool> cubitAlreadyRunningSomewhere(
      {Duration responseTimeout = const Duration(seconds: 1)}) async {
    final ping = IsolateNameServer.lookupPortByName(
        HeadphonesConnectionCubit.pingReceivePortName);
    if (ping == null) return false;
    final pong = ReceivePort();
    ping.send(pong.sendPort);
    return await pong.first.timeout(responseTimeout, onTimeout: () => false);
  }

  static Future<bool> killOtherCubit() async {
    final ping = IsolateNameServer.lookupPortByName(
        HeadphonesConnectionCubit.pingReceivePortName);
    if (ping == null) {
      loggI.e("No cubit to kill :( (this probably means you're using "
          "this function WRONG, or something WEIRD happened)");
      return true;
    }
    ping.send(_killUrself);
    if (await _checkUntilNoPort(killOtherCubitTimeout)) {
      return true;
    } else {
      loggI.e("Cubit didn't kill itself as nicely asked :(");
      return false;
    }
  }

  static const sppUuid = "00001101-0000-1000-8000-00805f9b34fb";

  Future<void> connect() async {
    if (_isClosed || _connection != null) return;

    final connected = _watchedKnownDevices.keys
        .firstWhereOrNull((dev) => dev.isConnected.valueOrNull ?? false);
    if (connected != null) {
      _connect(connected, matchModel(connected)!);
    }
  }

  Future<void> _connect(BluetoothDevice dev, MatchedModel model) async {
    if (_isClosed) {
      loggI.w("Attempted to connect after cubit was closed - ignoring");
      return;
    }

    final placeholder = model.placeholder;
    try {
      if (!_isClosed) emit(HeadphonesConnecting(placeholder));

      for (var i = 0; i < connectTries; i++) {
        try {
          if (_isClosed) return;
          _connection = _bluetooth.connectRfcomm(dev, sppUuid);
          break;
        } catch (_) {
          loggI.w('Error when connecting socket: ${i + 1}/$connectTries tries');
          if (!(dev.isConnected.valueOrNull ?? false)) {
            loggI.w("...i's because device is not connected, dummy 😌");
            rethrow;
          }
          if (i + 1 >= connectTries) rethrow;
          await Future.delayed(Duration(milliseconds: 50));
          if (_isClosed) return;
        }
      }

      if (_isClosed) return;
      emit(HeadphonesConnectedOpen(model.builder(_connection!, dev)));

      await _connection!.stream.listen((event) {}).asFuture();
    } catch (e, s) {
      loggI.e("Error while connecting to socket", error: e, stackTrace: s);
    }

    await _connection?.sink.close();
    _connection = null;

    if (_isClosed) return;
    if (!(_bluetooth.isEnabled.valueOrNull ?? false)) return;

    try {
      emit(
        (dev.isConnected.valueOrNull ?? false)
            ? HeadphonesConnectedClosed(placeholder)
            : HeadphonesDisconnected(placeholder),
      );
    } catch (e) {
      loggI.e("Error emitting state after connection closed", error: e);
    }
  }

  Future<void> _pairedDevicesHandle(Iterable<BluetoothDevice> devices) async {
    if (_isClosed) return;

    if (!(_bluetooth.isEnabled.valueOrNull ?? false)) {
      emit(const HeadphonesBluetoothDisabled());
      return;
    }

    final knownHeadphones = devices
        .map((dev) => (device: dev, match: matchModel(dev)))
        .where((m) => m.match != null);

    if (knownHeadphones.isEmpty) {
      emit(const HeadphonesNotPaired());
      return;
    }

    for (final hp in knownHeadphones) {
      if (!_watchedKnownDevices.containsKey(hp.device)) {
        _watchedKnownDevices[hp.device] =
            hp.device.isConnected.listen((connected) {
          if (_isClosed) return;
          if (connected) {
            if (_connection != null) return;
            _connect(hp.device, hp.match!);
          } else {
            _connection?.sink.close();
            _connection = null;
            if (!_isClosed) {
              emit(HeadphonesDisconnected(hp.match!.placeholder));
            }
          }
        });
      }
    }
    for (final dev in _watchedKnownDevices.keys) {
      if (!knownHeadphones.map((e) => e.device).contains(dev)) {
        _watchedKnownDevices[dev]!.cancel();
        _watchedKnownDevices.remove(dev);
      }
    }
  }

  HeadphonesConnectionCubit({required TheLastBluetooth bluetooth})
      : _bluetooth = bluetooth,
        super(const HeadphonesNotPaired()) {
    final rolex = Stopwatch()..start();
    _initInit().then(
      (_) => loggI.d("_initInit() took ${rolex.elapsedMilliseconds}ms"),
    );
  }

  Future<void> _initInit() async {
    if (await cubitAlreadyRunningSomewhere()) {
      loggI.w("Found already running cubit while init() - "
          "will wait $killOtherCubitTimeout and then kill it");
      if (await _checkUntilNoPort(killOtherCubitTimeout)) {
        loggI.i("Gone already, no need for war crimes 😇");
      } else {
        loggI.i("Killing other cubit...");
        if (!await killOtherCubit()) {
          loggI.f("Failed to kill other cubit 😵... well, anyway...");
        }
      }
    }

    IsolateNameServer.removePortNameMapping(pingReceivePortName);
    IsolateNameServer.registerPortWithName(
        _pingReceivePort.sendPort, pingReceivePortName);
    _pingReceivePortSS = _pingReceivePort.listen((message) {
      if (message is SendPort) message.send(true);
      if (message == _killUrself) {
        loggI.w("Killing myself bc other cubit asked to 😖");
        close();
      }
    });
    _warCrimesFinished = true;

    return _init();
  }

  Future<void> _init() async {
    if (_isClosed) return;

    if (_btEnabledStream != null) {
      loggI.w("_init() was already done and finished, but got called"
          "again. Weird.");
      return;
    }
    loggI.d("Starting init...");
    if (!_warCrimesFinished) {
      loggI.w("_init() called but _initInit() not finished 😵‍💫 - "
          "this isn't good, but we may survive this...");
      return;
    }
    if (!await Permission.bluetoothConnect.isGranted) {
      emit(const HeadphonesNoPermission());
      return;
    }
    _bluetooth.init();
    _btEnabledStream = _bluetooth.isEnabled.listen((enabled) {
      if (_isClosed) return;
      if (!enabled) emit(const HeadphonesBluetoothDisabled());
    });
    _devStream = _bluetooth.pairedDevices.listen(_pairedDevicesHandle);
  }

  Future<bool> enableBluetooth() async => false;

  Future<void> openBluetoothSettings() => AppSettings.openAppSettings(
      type: AppSettingsType.bluetooth, asAnotherTask: true);

  Future<void> requestPermission() async {
    await Permission.bluetoothConnect.request();
    await _init();
  }

  Future<void> tryConnectIfNeeded() async {
    if (_isClosed || _connection != null) return;

    if (!(_bluetooth.isEnabled.valueOrNull ?? false)) return;

    try {
      final pairedDevices = _bluetooth.pairedDevices.valueOrNull;
      if (pairedDevices == null || pairedDevices.isEmpty) return;

      final knownDevice = pairedDevices
          .map((dev) => (device: dev, match: matchModel(dev)))
          .where((m) => m.match != null)
          .firstOrNull;

      if (knownDevice != null &&
          (knownDevice.device.isConnected.valueOrNull ?? false)) {
        await _connect(knownDevice.device, knownDevice.match!);
        loggI.i('Automatic reconnection initiated');
      }
    } catch (e) {
      loggI.e("Error in tryConnectIfNeeded", error: e);
    }
  }

  @override
  Future<void> close() async {
    _isClosed = true;

    await _connection?.sink.close();
    await _btEnabledStream?.cancel();
    await _devStream?.cancel();
    for (final sub in _watchedKnownDevices.values) {
      await sub.cancel();
    }
    _watchedKnownDevices.clear();
    await _pingReceivePortSS.cancel();
    _pingReceivePort.close();
    IsolateNameServer.removePortNameMapping(pingReceivePortName);
    return super.close();
  }
}
