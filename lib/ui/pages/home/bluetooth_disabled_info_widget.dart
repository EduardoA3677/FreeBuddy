import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../headphones/cubit/headphones_connection_cubit.dart';
import '../../theme/dimensions.dart';

class BluetoothDisabledInfoWidget extends StatelessWidget {
  const BluetoothDisabledInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

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
              theme.colorScheme.errorContainer.withValues(alpha: 0.7),
              theme.colorScheme.errorContainer.withValues(alpha: 0.5),
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
                color: theme.colorScheme.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Symbols.bluetooth_disabled,
                size: AppDimensions.iconXLarge + 8,
                weight: 300,
                color: theme.colorScheme.error,
              ),
            ),
            SizedBox(height: AppDimensions.spacing24),
            Text(
              l.pageHomeBluetoothDisabled,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: AppDimensions.textXXLarge - 2,
                letterSpacing: -0.3,
                color: theme.colorScheme.onErrorContainer,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.spacing8),
            Text(
              'Activa el Bluetooth para conectar tus auriculares',
              style: textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.spacing24),
            FilledButton.icon(
              onPressed: () => context.read<HeadphonesConnectionCubit>().openBluetoothSettings(),
              icon: const Icon(Symbols.settings_bluetooth),
              label: Text(l.pageHomeBluetoothDisabledOpenSettings),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing24, vertical: AppDimensions.spacing16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                elevation: AppDimensions.elevationSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
