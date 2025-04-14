import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../headphones/cubit/headphones_connection_cubit.dart';
import '../../theme/dimensions.dart';

class NotPairedInfoWidget extends StatelessWidget {
  const NotPairedInfoWidget({super.key});

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
              theme.colorScheme.secondaryContainer.withValues(alpha: 0.9),
              theme.colorScheme.secondaryContainer.withValues(alpha: 0.6),
            ],
          ),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing24,
            vertical: AppDimensions.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppDimensions.spacing16),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Symbols.headphones,
                size: AppDimensions.iconXLarge + 8,
                weight: 300,
                color: theme.colorScheme.secondary,
              ),
            ),
            SizedBox(height: AppDimensions.spacing24),
            Text(
              l.pageHomeNotPaired,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: AppDimensions.textXXLarge - 2,
                letterSpacing: -0.3,
                color: theme.colorScheme.onSecondaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.spacing8),
            Text(
              'Empareja tus auriculares para usarlos con FreeBuddy',
              style: textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer
                    .withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.spacing24),
            FilledButton.icon(
              onPressed: () => context
                  .read<HeadphonesConnectionCubit>()
                  .openBluetoothSettings(),
              icon: const Icon(Symbols.settings_bluetooth),
              label: Text(l.pageHomeNotPairedPairOpenSettings),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
                padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing24,
                    vertical: AppDimensions.spacing16),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMedium),
                ),
              ),
            ),
            SizedBox(height: AppDimensions.spacing16),
            OutlinedButton.icon(
              onPressed: () => launchUrlString(
                'https://freebuddy-web-demo.netlify.app/',
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Symbols.open_in_new),
              label: Text(l.pageHomeNotPairedPairOpenDemo),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.secondary,
                side: BorderSide(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                    width: 1.5),
                padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing20,
                    vertical: AppDimensions.spacing12),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMedium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
