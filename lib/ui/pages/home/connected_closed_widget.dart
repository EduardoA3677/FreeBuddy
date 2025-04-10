import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../headphones/cubit/headphones_connection_cubit.dart';
import '../../../logger.dart';

class ConnectedClosedWidget extends StatelessWidget {
  const ConnectedClosedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final t = Theme.of(context);
    final tt = t.textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l.pageHomeConnectedClosed,
          style: tt.displaySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(l.pageHomeConnectedClosedDesc, textAlign: TextAlign.center),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: () {
            try {
              context.read<HeadphonesConnectionCubit>().connect();
            } catch (e) {
              log(LogLevel.error, 'Error connecting from UI', error: e);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(l.pageHomeConnectedClosedConnect),
          ),
        ),
      ],
    );
  }
}
