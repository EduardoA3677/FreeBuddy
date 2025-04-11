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
    // Lista completa de permisos que necesita la app
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
      Permission.storage,
      Permission.notification,
    ];

    // Agregar permisos opcionales según disponibilidad
    try {
      if (await Permission.manageExternalStorage.status != PermissionStatus.permanentlyDenied) {
        permissions.add(Permission.manageExternalStorage);
      }
    } catch (_) {
      // Permiso no disponible en este dispositivo
    }

    try {
      if (await Permission.ignoreBatteryOptimizations.status !=
          PermissionStatus.permanentlyDenied) {
        permissions.add(Permission.ignoreBatteryOptimizations);
      }
    } catch (_) {
      // Permiso no disponible en este dispositivo
    }

    // Verificar cuáles permisos aún no han sido concedidos
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

      // Si no hay permisos pendientes, notificar a la UI que todo está listo
      if (_pendingPermissions.isEmpty) {
        // Cerrar el diálogo si estamos dentro de uno
        if (ModalRoute.of(context)?.isCurrent == false) {
          Navigator.of(context).pop(true);
        }

        // Notificar al cubit que los permisos han sido concedidos
        context.read<HeadphonesConnectionCubit>().requestPermission();
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

  Future<void> _requestAllPermissions() async {
    setState(() {
      _isRequestingPermissions = true;
    });

    try {
      // Primero solicitar permisos de Bluetooth a través del cubit
      await context.read<HeadphonesConnectionCubit>().requestPermission();

      // Luego solicitar los permisos adicionales
      for (var permission in _pendingPermissions) {
        await permission.request();
      }

      // Verificar nuevamente cuáles siguen pendientes
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
}
