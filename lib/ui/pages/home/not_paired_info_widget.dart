import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../headphones/cubit/headphones_connection_cubit.dart';

class NotPairedInfoWidget extends StatelessWidget {
  const NotPairedInfoWidget({super.key});

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
              t.colorScheme.secondaryContainer.withValues(alpha: 0.9),
              t.colorScheme.secondaryContainer.withValues(alpha: 0.6),
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
                color: t.colorScheme.secondary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Symbols.headphones,
                size: 56,
                weight: 300,
                color: t.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l.pageHomeNotPaired,
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 22,
                letterSpacing: -0.3,
                color: t.colorScheme.onSecondaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Empareja tus auriculares para usarlos con FreeBuddy',
              style: tt.bodyMedium?.copyWith(
                color: t.colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.read<HeadphonesConnectionCubit>().openBluetoothSettings(),
              icon: const Icon(Symbols.settings_bluetooth),
              label: Text(l.pageHomeNotPairedPairOpenSettings),
              style: FilledButton.styleFrom(
                backgroundColor: t.colorScheme.secondary,
                foregroundColor: t.colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => launchUrlString(
                'https://freebuddy-web-demo.netlify.app/',
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Symbols.open_in_new),
              label: Text(l.pageHomeNotPairedPairOpenDemo),
              style: OutlinedButton.styleFrom(
                foregroundColor: t.colorScheme.secondary,
                side: BorderSide(color: t.colorScheme.secondary.withValues(alpha: 0.5), width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
