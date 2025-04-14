import 'dart:developer';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../headphones/cubit/headphones_connection_cubit.dart';
import '../../../logger.dart';
import '../../theme/dimensions.dart';

class NoPermissionInfoWidget extends StatefulWidget {
  const NoPermissionInfoWidget({super.key});

  @override
  State<NoPermissionInfoWidget> createState() => _NoPermissionInfoWidgetState();
}

class _NoPermissionInfoWidgetState extends State<NoPermissionInfoWidget>
    with WidgetsBindingObserver {
  bool _isRequestingPermissions = false;
  List<Permission> _pendingPermissions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPendingPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPendingPermissions();
    }
  }

  Future<void> _checkPendingPermissions() async {
    setState(() {
      _isRequestingPermissions = true;
    });

    final permissions = <Permission>[
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.notification,
      Permission.manageExternalStorage, // Added storage permission
    ];

    try {
      if (await Permission.bluetoothScan.status != PermissionStatus.granted &&
          await Permission.location.status != PermissionStatus.permanentlyDenied) {
        permissions.add(Permission.location);
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
        if (Navigator.of(context).canPop()) {
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
      final results = <Permission, PermissionStatus>{};

      for (final permission in _pendingPermissions) {
        final result = await permission.request();
        results[permission] = result;
      }

      final denied = results.entries
          .where((entry) => !entry.value.isGranted)
          .map((entry) => entry.key)
          .toList();

      if (denied.isEmpty) {
        if (mounted) {
          context.read<HeadphonesConnectionCubit>().requestPermission();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Todos los permisos fueron concedidos')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Faltan permisos: ${denied.map((e) => e.toString().split('.').last).join(', ')}')),
          );
        }
      }

      await _checkPendingPermissions();
    } catch (e, stackTrace) {
      log(LogLevel.error as String,
          name: 'Error al solicitar permisos', error: e, stackTrace: stackTrace);
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
      elevation: AppDimensions.elevationSmall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              t.colorScheme.tertiaryContainer.withAlpha(230),
              t.colorScheme.tertiaryContainer.withAlpha(153),
            ],
          ),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing24, vertical: AppDimensions.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppDimensions.spacing16),
              decoration: BoxDecoration(
                color: t.colorScheme.tertiary.withAlpha(38),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Symbols.security,
                size: AppDimensions.iconXLarge + 8,
                weight: 300,
                color: t.colorScheme.tertiary,
              ),
            ),
            SizedBox(height: AppDimensions.spacing24),
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
                color: t.colorScheme.onTertiaryContainer.withAlpha(204),
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
                backgroundColor: t.colorScheme.surface.withAlpha(230),
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
