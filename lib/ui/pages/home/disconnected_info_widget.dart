import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../headphones/cubit/headphones_connection_cubit.dart';
import '../../theme/dimensions.dart';

class DisconnectedInfoWidget extends StatelessWidget {
  const DisconnectedInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l.pageHomeDisconnected,
          style: textTheme.displaySmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppDimensions.spacing16),
        Text(
          l.pageHomeDisconnectedDesc,
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: AppDimensions.spacing16),
        ElevatedButton.icon(
          onPressed: () =>
              context.read<HeadphonesConnectionCubit>().openBluetoothSettings(),
          icon:
              Icon(Symbols.settings_bluetooth, size: AppDimensions.iconMedium),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing24,
                vertical: AppDimensions.spacing12),
            backgroundColor: theme.colorScheme.surfaceContainerHigh,
            foregroundColor: theme.colorScheme.primary,
            elevation: AppDimensions.elevationSmall,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
          ),
          label: Text(
            l.pageHomeDisconnectedOpenSettings,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppDimensions.textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
