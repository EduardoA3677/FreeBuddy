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
        child: Center(
          child: BlocBuilder<HeadphonesConnectionCubit, HeadphonesConnectionState>(
            builder: (context, state) {
              return switch (state) {
                HeadphonesConnectedOpen(:final headphones) =>
                    _StaticHeadphonesControlsWidget(headphones: headphones),
                HeadphonesDisconnected() => _DisconnectedWidget(theme: theme, l: l),
                HeadphonesNotPaired() => _NotPairedWidget(theme: theme, l: l),
                _ => const _LoadingWidget()
              };
            },
          ),
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

class _StaticHeadphonesControlsWidget extends StatelessWidget {
  final BluetoothHeadphones headphones;

  const _StaticHeadphonesControlsWidget({super.key, required this.headphones});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: HeadphonesControlsWidget(headphones: headphones),
    );
  }
}
