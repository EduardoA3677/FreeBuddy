import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:material_symbols_icons/symbols.dart';

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
      if (await Permission.ignoreBatteryOptimizations.status !=
          PermissionStatus.permanentlyDenied) {
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              t.colorScheme.tertiaryContainer.withValues(alpha: 0.9),
              t.colorScheme.tertiaryContainer.withValues(alpha: 0.6),
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: t.colorScheme.tertiary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Symbols.security,
                size: 56,
                weight: 300,
                color: t.colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l.pageHomeNoPermission,
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 22,
                letterSpacing: -0.3,
                color: t.colorScheme.onTertiaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Se necesitan permisos para conectar tus auriculares',
              style: tt.bodyMedium?.copyWith(
                color: t.colorScheme.onTertiaryContainer.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_isRequestingPermissions)
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: t.colorScheme.tertiary,
                ),
              )
            else
              FilledButton.icon(
                onPressed: _requestAllPermissions,
                icon: const Icon(Symbols.check_circle),
                label: Text(
                  l.pageHomeNoPermissionGrant,
                  textAlign: TextAlign.center,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: t.colorScheme.tertiary,
                  foregroundColor: t.colorScheme.onTertiary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => AppSettings.openAppSettings(asAnotherTask: true),
              icon: const Icon(Symbols.settings),
              label: Text(
                l.pageHomeNoPermissionOpenSettings,
                textAlign: TextAlign.center,
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: t.colorScheme.tertiary,
                backgroundColor: t.colorScheme.surface.withValues(alpha: 0.9),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
