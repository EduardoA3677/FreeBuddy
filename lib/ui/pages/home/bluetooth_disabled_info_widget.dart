import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../headphones/cubit/headphones_connection_cubit.dart';

class BluetoothDisabledInfoWidget extends StatelessWidget {
  const BluetoothDisabledInfoWidget({super.key});

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
              t.colorScheme.errorContainer.withValues(alpha: 0.7),
              t.colorScheme.errorContainer.withValues(alpha: 0.5),
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
                color: t.colorScheme.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Symbols.bluetooth_disabled,
                size: 56,
                weight: 300,
                color: t.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l.pageHomeBluetoothDisabled,
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 22,
                letterSpacing: -0.3,
                color: t.colorScheme.onErrorContainer,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Activa el Bluetooth para conectar tus auriculares',
              style: tt.bodyMedium?.copyWith(
                color: t.colorScheme.onErrorContainer.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // the_last_bluetooth plugin doesn't support this for now
            // TextButton(
            //   onPressed: onEnable,
            //   child: Text(l.pageHomeBluetoothDisabledEnable),
            // ),
            FilledButton.icon(
              onPressed: () => context.read<HeadphonesConnectionCubit>().openBluetoothSettings(),
              icon: const Icon(Symbols.settings_bluetooth),
              label: Text(l.pageHomeBluetoothDisabledOpenSettings),
              style: FilledButton.styleFrom(
                backgroundColor: t.colorScheme.primary,
                foregroundColor: t.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
