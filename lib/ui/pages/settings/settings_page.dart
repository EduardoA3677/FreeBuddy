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
            // Sección de Configuración del Tema
            _buildSectionHeader(context, l.themeSettingsTitle),
            const SizedBox(height: 8),
            _buildThemeSettings(context),

            const SizedBox(height: 24),

            // Sección de Opciones de Depuración
            _buildSectionHeader(context, l.debugSettingsTitle),
            const SizedBox(height: 8),
            _buildDebugSettings(context),

            const SizedBox(height: 24),

            // Sección de Acerca de la App (original)
            FilledButton(
              onPressed: () => GoRouter.of(context).push('/settings/about'),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(l.pageAboutTitle),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para construir el encabezado de una sección
  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Configuración del tema
  Widget _buildThemeSettings(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final settings = context.read<AppSettings>();

    return StreamBuilder<ThemeMode>(
      stream: settings.themeMode,
      initialData: ThemeMode.system,
      builder: (context, snapshot) {
        final currentTheme = snapshot.data!;

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
                  onChanged: (value) => settings.setThemeMode(ThemeMode.system),
                ),
                RadioListTile<ThemeMode>(
                  title: Text(l.themeSettingsLight),
                  value: ThemeMode.light,
                  groupValue: currentTheme,
                  onChanged: (value) => settings.setThemeMode(ThemeMode.light),
                ),
                RadioListTile<ThemeMode>(
                  title: Text(l.themeSettingsDark),
                  value: ThemeMode.dark,
                  groupValue: currentTheme,
                  onChanged: (value) => settings.setThemeMode(ThemeMode.dark),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Opciones de depuración
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
            // Opción para activar/desactivar el modo debug
            StreamBuilder<bool>(
              stream: settings.debugMode,
              initialData: false,
              builder: (context, snapshot) {
                final isDebugEnabled = snapshot.data!;

                return SwitchListTile(
                  title: Text(l.debugModeEnable),
                  subtitle: Text(l.debugModeDescription),
                  value: isDebugEnabled,
                  onChanged: (value) => settings.setDebugMode(value),
                );
              },
            ),

            const Divider(),

            // Botón para exportar logs
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

  // Método para exportar logs a un archivo
  Future<void> _exportLogs(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final snackBar = ScaffoldMessenger.of(context);

    try {
      // Obtener el directorio de documentos
      final directory =
          await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();

      // Crear el nombre del archivo con timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '_');
      final filePath = '${directory.path}/freebuddy_logs_$timestamp.log';

      // Obtener logs y escribirlos al archivo
      final logContents = AppLogger.getLogContent();
      final file = File(filePath);
      await file.writeAsString(logContents);

      // Mostrar mensaje de éxito
      snackBar.showSnackBar(SnackBar(
        content: Text('${l.exportLogsSuccess}: $filePath'),
        backgroundColor: Colors.green,
      ));

      log(LogLevel.info, 'Logs exported to: $filePath');
    } catch (e, stackTrace) {
      // Mostrar mensaje de error
      snackBar.showSnackBar(SnackBar(
        content: Text('${l.exportLogsError}: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));

      log(LogLevel.error, 'Error exporting logs', error: e, stackTrace: stackTrace);
    }
  }
}
