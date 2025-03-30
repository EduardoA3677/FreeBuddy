import 'package:rxdart/rxdart.dart';

/// Represents a device that can be connected via DualConnect feature
class DualConnectDevice {
  final String name;
  final String mac;
  final bool preferred;
  final bool connected;
  final bool playing;
  final bool? autoConnect;

  const DualConnectDevice({
    required this.name,
    required this.mac,
    required this.preferred,
    required this.connected,
    required this.playing,
    this.autoConnect,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'auto_connect': autoConnect,
    'preferred': preferred,
    'connected': connected,
    'playing': playing,
  };

  @override
  String toString() => 'DualConnectDevice($name, $mac, preferred: $preferred, '
      'connected: $connected, playing: $playing, autoConnect: $autoConnect)';
}

enum DualConnCommand {
  connect,
  disconnect,
  unpair,
  enableAuto,
  disableAuto;

  int get mbbCode => index + 1;
}

/// Framework interface for devices that support DualConnect feature
abstract class DualConnect {
  /// Whether DualConnect is enabled
  ValueStream<bool> get dualConnectEnabled;

  /// List of currently available dual-connect devices
  ValueStream<Map<String, DualConnectDevice>> get dualConnectDevices;

  /// Mac address of the preferred device
  ValueStream<String> get preferredDeviceMac;

  /// Enable or disable DualConnect feature
  Future<void> setDualConnectEnabled(bool enabled);

  /// Set the preferred device by MAC address
  Future<void> setPreferredDevice(String mac);

  /// Execute a command on a specific device by MAC address
  Future<void> executeDualConnCommand(String mac, DualConnCommand command);
  
  /// Refresh the list of devices
  Future<void> refreshDeviceList();
}