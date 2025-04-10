import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../headphones/cubit/headphones_connection_cubit.dart';
import '../../../logger.dart';

class NoPermissionInfoWidget extends StatefulWidget {
  const NoPermissionInfoWidget({super.key});

  @override
  State<NoPermissionInfoWidget> createState() => _NoPermissionInfoWidgetState();
}

class _NoPermissionInfoWidgetState extends State<NoPermissionInfoWidget> {
  bool _isRequestingPermissions = false;
  List<Permission> _pendingPermissions = [];

  @override
  void initState() {
    super.initState();
    _checkPendingPermissions();
  }

  Future<void> _checkPendingPermissions() async {
    setState(() {
      _isRequestingPermissions = true;
    });

    final permissions = <Permission>[
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.notification, // Android 13+
    ];

    try {
      if (await Permission.bluetoothScan.status != PermissionStatus.granted &&
          await Permission.location.status != PermissionStatus.permanentlyDenied) {
        permissions.add(Permission.location);
      }
    } catch (_) {}

    try {
      if (await Permission.manageExternalStorage.status != PermissionStatus.permanentlyDenied) {
        permissions.add(Permission.manageExternalStorage);
      }
    } catch (_) {}

    try {
      if (await Permission.ignoreBatteryOptimizations.status != PermissionStatus.permanentlyDenied) {
        permissions.add(Permission.ignoreBatteryOptimizations);
      }
    } catch (_) {}

    _pendingPermissions = [];
    for (var permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        _pendingPermissions.add(permission);
      }
    }

    if (mounted) {
      setState(() {
        _isRequestingPermissions = false;
      });

      if (_pendingPermissions.isEmpty) {
        if (ModalRoute.of(context)?.isCurrent == false) {
          Navigator.of(context).pop(true);
        }

        if (context.mounted) {
          context.read<HeadphonesConnectionCubit>().requestPermission();
        }
      }
    }
  }

  Future<void> _requestAllPermissions() async {
    setState(() {
      _isRequestingPermissions = true;
    });

    try {
      await context.read<HeadphonesConnectionCubit>().requestPermission();

      for (var permission in _pendingPermissions) {
        await permission.request();
      }

      await _checkPendingPermissions();
    } catch (e, stackTrace) {
      log(LogLevel.error, 'Error al solicitar permisos', error: e, stackTrace: stackTrace);
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingPermissions = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final t = Theme.of(context);
    final tt = t.textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.pageHomeNoPermission,
              style: tt.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_isRequestingPermissions)
              const CircularProgressIndicator()
            else
              FilledButton(
                onPressed: _requestAllPermissions,
                child: Text(
                  l.pageHomeNoPermissionGrant,
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => AppSettings.openAppSettings(asAnotherTask: true),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  l.pageHomeNoPermissionOpenSettings,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
