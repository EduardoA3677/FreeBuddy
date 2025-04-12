import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../../logger.dart';
import '../../app_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final settings = context.read<AppSettings>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.settings,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, l.themeSettingsTitle),
            const SizedBox(height: 12),
            _buildThemeSettings(context, settings),
            const SizedBox(height: 24),
            _buildSectionHeader(context, l.debugSettingsTitle),
            const SizedBox(height: 12),
            _buildDebugSettings(context, settings),
            const SizedBox(height: 24),
            _buildAboutButton(context, l),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildThemeSettings(BuildContext context, AppSettings settings) {
    final l = AppLocalizations.of(context)!;

    return StreamBuilder<ThemeMode>(
      stream: settings.themeMode,
      initialData: ThemeMode.system,
      builder: (context, snapshot) {
        final currentTheme = snapshot.data ?? ThemeMode.system;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildDebugSettings(BuildContext context, AppSettings settings) {
    final l = AppLocalizations.of(context)!;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton.icon(
        onPressed: () => GoRouter.of(context).push('/settings/about'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        icon: const Icon(Icons.info),
        label: Text(
          l.pageAboutTitle,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Future<void> _exportLogs(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final snackBar = ScaffoldMessenger.of(context);

    try {
      final result = await FilePicker.platform.getDirectoryPath();
      if (result == null) return; // User canceled the picker

      final filePath = '$result/log.txt';
      final logContents = AppLogger.getLogContent();
      final file = File(filePath);
      await file.writeAsString(logContents);

      if (!context.mounted) return;
      snackBar.showSnackBar(SnackBar(
        content: Text('${l.exportLogsSuccess}: $filePath'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      if (!context.mounted) return;
      snackBar.showSnackBar(SnackBar(
        content: Text('${l.exportLogsError}: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }
}
