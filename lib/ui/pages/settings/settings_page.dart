import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l.settings),
        backgroundColor: Theme.of(context)
            .colorScheme
            .surface
            .withAlpha(242), // ~0.95 opacity
        elevation: 0,
      ),
      body: SafeArea(
        top: false, // No aplicar padding superior ya que el AppBar lo maneja
        child: Center(
          child: ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            children: [
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed('/settings/about'),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(l.pageAboutTitle),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
