import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../headphones/cubit/headphones_connection_cubit.dart';
import '../../../headphones/cubit/headphones_cubit_objects.dart';
import '../../app_settings.dart';
import 'controls/headphones_controls_widget.dart';
import 'no_permission_info_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_handleStartupFlow);
  }

  Future<void> _handleStartupFlow() async {
    final settings = context.read<AppSettings>();
    if (!(await settings.seenIntroduction.first)) {
      if (!mounted) return;
      final success = await GoRouter.of(context).push('/introduction') as bool?;
      if (success == true && mounted) {
        await settings.setSeenIntroduction(true);
        await _checkPermissions();
      }
    } else {
      await _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final hasAllPermissions = await _hasAllRequiredPermissions();
    if (!hasAllPermissions && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.pageHomeNoPermission),
          content: const NoPermissionInfoWidget(),
        ),
      );
    }
  }

  Future<bool> _hasAllRequiredPermissions() async {
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ];
    return Future.wait(permissions.map((p) => p.isGranted))
        .then((results) => results.every((granted) => granted));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest, // Fondo ligeramente más oscuro
      appBar: AppBar(
        title: Text(
          l.appTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: -0.3,
          ),
        ),
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
        actions: [
          IconButton(
            icon: const Icon(Symbols.settings, weight: 300),
            tooltip: l.settings,
            onPressed: () => context.push('/settings'),
            style: IconButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: BlocBuilder<HeadphonesConnectionCubit, HeadphonesConnectionState>(
                builder: (context, state) {
                  return switch (state) {
                    HeadphonesConnectedOpen(:final headphones) =>
                        _ResponsiveHeadphonesControlsWidget(headphones: headphones),
                    HeadphonesDisconnected() => _DisconnectedWidget(theme: theme, l: l),
                    HeadphonesNotPaired() => _NotPairedWidget(theme: theme, l: l),
                    _ => const _LoadingWidget()
                  };
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/headphones_settings'),
        tooltip: l.pageHeadphonesSettingsTitle,
        elevation: 6, // Mayor elevación para un efecto más prominente
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
        extendedIconLabelSpacing: 16, // Mayor espacio entre el ícono y el texto
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Bordes más redondeados
        ),
        label: Text(
          l.pageHeadphonesSettingsTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            fontSize: 16, // Ajuste en el tamaño del texto
          ),
        ),
        icon: const Icon(Symbols.settings, weight: 300),
      ),
    );
  }
}

class _ResponsiveHeadphonesControlsWidget extends StatelessWidget {
  final BluetoothHeadphones headphones;

  const _ResponsiveHeadphonesControlsWidget({super.key, required this.headphones});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final widgetWidth = screenSize.width * 0.9; // Ajusta el ancho al 90% de la pantalla
    final widgetHeight = screenSize.height * 0.8; // Ajusta la altura al 80% de la pantalla

    return Center(
      child: SizedBox(
        width: widgetWidth,
        height: widgetHeight,
        child: HeadphonesControlsWidget(headphones: headphones),
      ),
    );
  }
}

class _DisconnectedWidget extends StatelessWidget {
  const _DisconnectedWidget({required this.theme, required this.l});

  final ThemeData theme;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Symbols.headset_off, size: 60, weight: 300, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            l.headphonesDisconnected,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.read<HeadphonesConnectionCubit>().connect(),
            icon: const Icon(Symbols.bluetooth_searching),
            label: Text(l.connect),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotPairedWidget extends StatelessWidget {
  const _NotPairedWidget({required this.theme, required this.l});

  final ThemeData theme;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Symbols.bluetooth_disabled,
            size: 60,
            weight: 300,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l.headphonesNotPaired,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.read<HeadphonesConnectionCubit>().openBluetoothSettings(),
            icon: const Icon(Symbols.settings_bluetooth),
            label: Text(l.configureBluetooth),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(strokeWidth: 3),
          const SizedBox(height: 24),
          Text(
            l.connectingToHeadphones,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
