import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../logger.dart';
import '../../app_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, l.themeSettingsTitle),
            const SizedBox(height: 8),
            _buildThemeSettings(context),
            const SizedBox(height: 24),
            _buildSectionHeader(context, l.debugSettingsTitle),
            const SizedBox(height: 8),
            _buildDebugSettings(context),
            const SizedBox(height: 24),
            _buildAboutButton(context, l),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildThemeSettings(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final settings = context.read<AppSettings>();

    return StreamBuilder<ThemeMode>(
      stream: settings.themeMode,
      initialData: ThemeMode.system,
      builder: (context, snapshot) {
        final currentTheme = snapshot.data ?? ThemeMode.system;

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RadioListTile<ThemeMode>(
                  title: Text(l.themeSettingsSystem),
                  value: ThemeMode.system,
                  groupValue: currentTheme,
                  onChanged: (value) {
                    if (value != null) {
                      settings.setThemeMode(value);
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: Text(l.themeSettingsLight),
                  value: ThemeMode.light,
                  groupValue: currentTheme,
                  onChanged: (value) {
                    if (value != null) {
                      settings.setThemeMode(value);
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: Text(l.themeSettingsDark),
                  value: ThemeMode.dark,
                  groupValue: currentTheme,
                  onChanged: (value) {
                    if (value != null) {
                      settings.setThemeMode(value);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDebugSettings(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final settings = context.read<AppSettings>();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<bool>(
              stream: settings.debugMode,
              initialData: false,
              builder: (context, snapshot) {
                final isDebugEnabled = snapshot.data ?? false;

                return SwitchListTile(
                  title: Text(l.debugModeEnable),
                  subtitle: Text(l.debugModeDescription),
                  value: isDebugEnabled,
                  onChanged: (value) => settings.setDebugMode(value),
                );
              },
            ),
            const Divider(),
            ListTile(
              title: Text(l.exportLogs),
              subtitle: Text(l.exportLogsDescription),
              trailing: const Icon(Symbols.download),
              onTap: () => _exportLogs(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutButton(BuildContext context, AppLocalizations l) {
    return FilledButton(
      onPressed: () => GoRouter.of(context).push('/settings/about'),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(l.pageAboutTitle),
      ),
    );
  }

  Future<void> _exportLogs(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final snackBar = ScaffoldMessenger.of(context);

    try {
      final directory =
          await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '_');
      final filePath = '${directory.path}/freebuddy_logs_$timestamp.log';

      final logContents = AppLogger.getLogContent();
      final file = File(filePath);
      await file.writeAsString(logContents);

      snackBar.showSnackBar(SnackBar(
        content: Text('${l.exportLogsSuccess}: $filePath'),
        backgroundColor: Colors.green,
      ));

      log(LogLevel.info, 'Logs exported to: $filePath');
    } catch (e, stackTrace) {
      snackBar.showSnackBar(SnackBar(
        content: Text('${l.exportLogsError}: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));

      log(LogLevel.error, 'Error exporting logs', error: e, stackTrace: stackTrace);
    }
  }
}
