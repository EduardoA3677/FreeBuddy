import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../headphones/cubit/headphones_connection_cubit.dart';
import '../../../headphones/cubit/headphones_cubit_objects.dart';
import '../../../headphones/framework/bluetooth_headphones.dart';
import '../../app_settings.dart';
import 'controls/headphones_controls_widget.dart';
import 'no_permission_info_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(_introCheck);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _introCheck() async {
    final ctx = context;
    final settings = ctx.read<AppSettings>();
    if (!(await settings.seenIntroduction.first)) {
      if (!ctx.mounted) return;
      final success = await GoRouter.of(ctx).push('/introduction') as bool?;
      if (success ?? false) {
        await settings.setSeenIntroduction(true);
        // Después de ver la introducción y marcarla como vista,
        // verificar los permisos necesarios
        if (ctx.mounted) {
          _checkPermissions();
        }
      }
    } else {
      // Si ya se vio la introducción, verificar los permisos
      _checkPermissions();
    }
  }

  void _checkPermissions() async {
    // Verificar si todos los permisos ya están concedidos
    final hasAllPermissions = await _hasAllRequiredPermissions();
    if (!hasAllPermissions && mounted) {
      // Mostrar diálogo de permisos si falta alguno
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.pageHomeNoPermission),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NoPermissionInfoWidget(),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<bool> _hasAllRequiredPermissions() async {
    final requiredPermissions = [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ];

    for (var permission in requiredPermissions) {
      if (!(await permission.isGranted)) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.appTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: -0.3,
          ),
        ),
        elevation: 0,
        scrolledUnderElevation: 1.0,
        centerTitle: false,
        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
        actions: [
          IconButton(
            icon: const Icon(Symbols.settings, weight: 300),
            tooltip: l.settings,
            onPressed: () => GoRouter.of(context).push('/settings'),
            style: IconButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Widget principal con los controles
              Expanded(
                child: BlocBuilder<HeadphonesConnectionCubit, HeadphonesConnectionState>(
                  builder: (context, state) {
                    if (state is HeadphonesConnectedOpen) {
                      // Extraer información del modelo si es un dispositivo Huawei
                      BluetoothHeadphones headphones = state.headphones;

                      // Mostrar el widget de control de auriculares
                      return HeadphonesControlsWidget(
                        headphones: headphones,
                      );
                    } else if (state is HeadphonesDisconnected) {
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Symbols.headset_off,
                                  size: 72, weight: 300, color: theme.colorScheme.error),
                              const SizedBox(height: 24),
                              Text(
                                l.headphonesDisconnected,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 22,
                                  letterSpacing: -0.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: () =>
                                    context.read<HeadphonesConnectionCubit>().connect(),
                                icon: const Icon(Symbols.bluetooth_searching),
                                label: Text('Conectar'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms).scale(
                            begin: Offset(0.9, 0.9), end: Offset(1.0, 1.0), duration: 400.ms),
                      );
                    } else if (state is HeadphonesNotPaired) {
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Symbols.bluetooth_disabled,
                                  size: 72, weight: 300, color: theme.colorScheme.onSurfaceVariant),
                              const SizedBox(height: 24),
                              Text(
                                l.headphonesNotPaired,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 22,
                                  letterSpacing: -0.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: () => context
                                    .read<HeadphonesConnectionCubit>()
                                    .openBluetoothSettings(),
                                icon: const Icon(Symbols.settings_bluetooth),
                                label: Text('Configurar Bluetooth'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: theme.colorScheme.secondary,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms).scale(
                            begin: Offset(0.9, 0.9), end: Offset(1.0, 1.0), duration: 400.ms),
                      );
                    } else {
                      // Estado de carga o esperando
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Conectando con tus auriculares...',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              )
                  .animate(controller: _controller)
                  .fadeIn(duration: 600.ms, delay: 200.ms, curve: Curves.easeOutQuad),
            ],
          ),
        ),
      ),
      // Botón flotante para ir rápidamente a la configuración de los auriculares
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => GoRouter.of(context).push('/headphones_settings'),
        tooltip: l.pageHeadphonesSettingsTitle,
        elevation: 3,
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
        extendedIconLabelSpacing: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        label: Text(
          'Configuración',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        icon: const Icon(Symbols.settings, weight: 300),
      ).animate(controller: _controller).scale(
          begin: const Offset(0.0, 0.0),
          end: const Offset(1.0, 1.0),
          duration: 400.ms,
          delay: 400.ms,
          curve: Curves.elasticOut),
    );
  }
}
