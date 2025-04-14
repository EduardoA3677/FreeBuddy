import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../headphones/cubit/headphones_connection_cubit.dart';
import '../../headphones/cubit/headphones_cubit_objects.dart';
import '../../headphones/framework/bluetooth_headphones.dart';
import '../pages/disabled.dart';
import '../pages/home/bluetooth_disabled_info_widget.dart';
import '../pages/home/connected_closed_widget.dart';
import '../pages/home/disconnected_info_widget.dart';
import '../pages/home/no_permission_info_widget.dart';
import '../pages/home/not_paired_info_widget.dart';
import '../theme/dimensions.dart';

/// Este componente escucha a [HeadphonesConnectionCubit] y decide si debe:
/// - Mostrar información sobre permisos de Bluetooth no concedidos/habilitados
/// - Mostrar un widget deshabilitado con información sobre la desconexión
/// - Mostrar el widget principal cuando todo está correcto
///
/// Cuando los auriculares están emparejados pero no conectados, proporciona un
/// objeto [HeadphonesMockNever], evita que el usuario interactúe con él y
/// muestra un mensaje apropiado.
///
/// Debe usarse en todas las pantallas que requieran auriculares conectados.
class HeadphonesConnectionEnsuringOverlay extends StatelessWidget {
  /// Función para construir el widget principal cuando los auriculares están conectados
  final Widget Function(BuildContext context, BluetoothHeadphones headphones)
      builder;

  const HeadphonesConnectionEnsuringOverlay({super.key, required this.builder});

  Widget _padded(Widget child) =>
      Padding(padding: EdgeInsets.all(AppDimensions.spacing16), child: child);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final l = AppLocalizations.of(context)!;

    return BlocBuilder<HeadphonesConnectionCubit, HeadphonesConnectionState>(
      builder: (context, state) => switch (state) {
        HeadphonesNoPermission() => _padded(const NoPermissionInfoWidget()),
        HeadphonesNotPaired() => _padded(const NotPairedInfoWidget()),
        HeadphonesBluetoothDisabled() =>
          _padded(const BluetoothDisabledInfoWidget()),
        // Sabemos que tenemos los auriculares, pero no necesariamente conectados
        HeadphonesDisconnected() ||
        HeadphonesConnecting() ||
        HeadphonesConnectedClosed() ||
        HeadphonesConnectedOpen() =>
          Disabled(
            disabled: state is! HeadphonesConnectedOpen,
            coveringWidget: switch (state) {
              HeadphonesDisconnected() => const DisconnectedInfoWidget(),
              HeadphonesConnecting() => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l.pageHomeConnecting,
                        style: textTheme.displaySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500)),
                    SizedBox(height: AppDimensions.spacing16),
                    CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                      strokeWidth: 3,
                    ),
                  ],
                ),
              HeadphonesConnectedClosed() => const ConnectedClosedWidget(),
              // El widget Disabled() tiene una transición, así que necesitamos cambiar
              // el overlay incluso cuando está conectado
              HeadphonesConnectedOpen() => const SizedBox(),
              _ => Text(l.pageHomeUnknown,
                  style: textTheme.titleLarge
                      ?.copyWith(color: theme.colorScheme.error)),
            },
            child: builder(
              context,
              switch (state) {
                HeadphonesConnectedOpen(headphones: final hp) => hp,
                HeadphonesDisconnected(placeholder: final ph) ||
                HeadphonesConnecting(placeholder: final ph) ||
                HeadphonesConnectedClosed(placeholder: final ph) =>
                  ph,
                _ => throw 'impossible :O'
              },
            ),
          ),
        _ => Text(l.pageHomeUnknown,
            style:
                textTheme.titleLarge?.copyWith(color: theme.colorScheme.error)),
      },
    );
  }
}
