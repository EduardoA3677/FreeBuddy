import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../headphones/framework/bluetooth_headphones.dart';
import '../../../headphones/framework/headphones_info.dart';
import '../../../headphones/huawei/huawei_headphones_base.dart';
import '../../../headphones/huawei/huawei_headphones_impl.dart';
import '../../../headphones/model_definition/huawei_models_definition.dart';
import '../../common/headphones_connection_ensuring_overlay.dart';
import '../home/controls/headphones_image.dart';
import 'huawei/auto_pause_section.dart';
import 'huawei/double_tap_section.dart';
import 'huawei/hold_section.dart';

/// Página mejorada de configuración de auriculares
class HeadphonesSettingsPage extends StatelessWidget {
  const HeadphonesSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.pageHeadphonesSettingsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Symbols.help_outline),
            tooltip: 'Help',
            onPressed: () => _showHelpDialog(context, l),
          ),
        ],
      ),
      body: SafeArea(
        child: HeadphonesConnectionEnsuringOverlay(
          builder: (_, headphones) => _buildSettingsContent(headphones, context, theme),
        ),
      ),
    );
  }

  /// Construye el contenido principal de la pantalla de configuración
  Widget _buildSettingsContent(
      BluetoothHeadphones headphones, BuildContext context, ThemeData theme) {
    // Verificar si es un modelo compatible con la configuración detallada
    if (headphones is HuaweiHeadphonesBase) {
      return ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        children: _buildSettingsWidgets(headphones, context),
      );
    } else {
      // Mostrar mensaje de dispositivo no compatible
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Symbols.headset_off,
                size: 72,
                color: theme.colorScheme.error,
              ).animate().scale(
                    duration: 400.ms,
                    curve: Curves.elasticOut,
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                  ),
              const SizedBox(height: 24),
              Text(
                'Auriculares no compatibles',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Este dispositivo no es compatible con configuraciones avanzadas.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  /// Muestra un diálogo de ayuda con información sobre la configuración
  void _showHelpDialog(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configuración de auriculares'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'En esta sección puedes personalizar el comportamiento de tus auriculares:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              context,
              icon: Symbols.play_pause,
              title: 'Pausa automática',
              description: 'Configura si los auriculares pausan la música al quitártelos.',
            ),
            const SizedBox(height: 12),
            _buildHelpItem(
              context,
              icon: Symbols.touch_app,
              title: 'Doble toque',
              description:
                  'Personaliza la acción que se realiza al tocar dos veces cada auricular.',
            ),
            const SizedBox(height: 12),
            _buildHelpItem(
              context,
              icon: Symbols.pan_tool,
              title: 'Mantener pulsado',
              description: 'Configura qué ocurre al mantener pulsado cada auricular.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  /// Construye un elemento individual de la ayuda
  Widget _buildHelpItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Construye los widgets de configuración basados en el modelo de auriculares
List<Widget> _buildSettingsWidgets(BluetoothHeadphones headphones, BuildContext context) {
  if (headphones is HuaweiHeadphonesBase) {
    final huaweiBase = headphones;
    HuaweiModelDefinition? modelDef;

    if (headphones is HuaweiHeadphonesImpl) {
      modelDef = (headphones).modelDefinition;
    }

    final sections = <Widget>[];
    final theme = Theme.of(context);

    // Mostrar información del modelo y la imagen cuando sea posible
    if (modelDef != null) {
      // Añadir tarjeta de información de dispositivo
      sections.add(
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Imagen de auriculares
                  Container(
                    height: 140,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: HeadphonesImage(headphones as HeadphonesModelInfo)
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0)),
                  ),
                  const SizedBox(height: 8), // Información del modelo
                  Text(
                    '${modelDef.vendor} ${modelDef.name}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configura tu dispositivo',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
      );
    }

    // Opciones de configuración
    Widget buildSection(String title, IconData icon, Widget content) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          elevation: 1,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Icon(icon, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              content,
            ],
          ),
        ),
      );
    }

    // Añadir sección de pausa automática si es compatible
    if (modelDef?.supportsAutoPause ?? false) {
      sections.add(
        buildSection(
          'Pausa automática',
          Symbols.pause_circle,
          AutoPauseSection(huaweiBase),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.05, end: 0),
      );
    }

    // Añadir sección de doble toque si es compatible
    if (modelDef?.supportsDoubleTap ?? true) {
      sections.add(
        buildSection(
          'Acción de doble toque',
          Symbols.touch_app,
          DoubleTapSection(huaweiBase),
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.05, end: 0),
      );
    }

    // Añadir sección de mantener pulsado si es compatible
    if (modelDef?.supportsHold ?? true) {
      sections.add(
        buildSection(
          'Acción de mantener pulsado',
          Symbols.pan_tool,
          HoldSection(huaweiBase),
        ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.05, end: 0),
      );
    }

    return sections;
  } else {
    throw "You shouldn't be on this screen if you don't have settings!";
  }
}
