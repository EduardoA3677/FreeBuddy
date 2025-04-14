import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../headphones/cubit/headphones_connection_cubit.dart';
import '../../theme/dimensions.dart';

class ConnectedClosedWidget extends StatelessWidget {
  const ConnectedClosedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l.pageHomeConnectedClosed,
          style: textTheme.displaySmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppDimensions.spacing16),
        Text(
          l.pageHomeConnectedClosedDesc,
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: AppDimensions.spacing32),
        FilledButton(
          onPressed: () => context.read<HeadphonesConnectionCubit>().connect(),
          style: FilledButton.styleFrom(
            padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing28,
                vertical: AppDimensions.spacing16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            ),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: AppDimensions.elevationSmall,
          ),
          child: Text(
            l.pageHomeConnectedClosedConnect,
            style: TextStyle(
              fontSize: AppDimensions.textMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
