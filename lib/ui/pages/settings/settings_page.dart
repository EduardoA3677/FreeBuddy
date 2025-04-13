import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../../logger.dart';
import '../../app_settings.dart';
import '../../theme/dimensions.dart';
import '../../theme/theme_selector.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final settings = context.read<AppSettings>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.settings,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: AppDimensions.textXXLarge - 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: AppDimensions.elevationXSmall,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, l.themeSettingsTitle),
            SizedBox(height: AppDimensions.spacing12),
            const ThemeSelector(),
            SizedBox(height: AppDimensions.spacing24),
            _buildSectionHeader(context, l.debugSettingsTitle),
            SizedBox(height: AppDimensions.spacing12),
            _buildDebugSettings(context, settings),
            SizedBox(height: AppDimensions.spacing24),
            _buildAboutButton(context, l),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing8),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: AppDimensions.textLarge,
        ),
      ),
    );
  }

  Widget _buildDebugSettings(BuildContext context, AppSettings settings) {
    final l = AppLocalizations.of(context)!;

    return Card(
      elevation: AppDimensions.elevationSmall,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.spacing16),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  contentPadding: AppDimensions.listTilePadding,
                );
              },
            ),
            Divider(
              thickness: 0.8,
              height: AppDimensions.spacing32,
              indent: AppDimensions.spacing8,
              endIndent: AppDimensions.spacing8,
            ),
            ListTile(
              title: Text(l.exportLogs),
              subtitle: Text(l.exportLogsDescription),
              trailing: Icon(Symbols.download, size: AppDimensions.iconMedium),
              onTap: () => _exportLogs(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              contentPadding: AppDimensions.listTilePadding,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutButton(BuildContext context, AppLocalizations l) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing16),
      child: ElevatedButton.icon(
        onPressed: () => GoRouter.of(context).push('/settings/about'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
              vertical: AppDimensions.spacing12, horizontal: AppDimensions.spacing24),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: AppDimensions.elevationSmall,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
        ),
        icon: Icon(Symbols.info, size: AppDimensions.iconMedium),
        label: Text(
          l.pageAboutTitle,
          style: TextStyle(
            fontSize: AppDimensions.textLarge,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<String?> _getFileNameAndPath(BuildContext context) async {
    final initialDirectory = (await getDownloadsDirectory())?.path ??
        (await getDownloadsDirectory()).path;

    if (!context.mounted) return null;

    return showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.exportLogsDialog),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'log.txt'),
              ),
              const SizedBox(height: 12),
              Text('Directory: $initialDirectory'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, null),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                final fileName = controller.text.trim();
                Navigator.pop(dialogContext, '$initialDirectory/$fileName');
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportLogs(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final snackBar = ScaffoldMessenger.of(context);

    try {
      final filePath = await _getFileNameAndPath(context);
      if (filePath == null || filePath.isEmpty) return; // User canceled the dialog

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
