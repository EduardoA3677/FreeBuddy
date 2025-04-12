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
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        elevation: 0,
        scrolledUnderElevation: 1.0,
        centerTitle: false,
        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
        actions: [
          IconButton(
            icon: Icon(Symbols.help_outline, weight: 300),
            tooltip: 'Help',
            style: IconButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
            onPressed: () => _showHelpDialog(context, l),
          ),
        ],
      ),
      body: SafeArea(
        child: HeadphonesConnectionEnsuringOverlay(
          builder: (_, headphones) => _buildSettingsContent(headphones, context, theme, l),
        ),
      ),
    );
  }

  /// Construye el contenido principal de la pantalla de configuración
  Widget _buildSettingsContent(
      BluetoothHeadphones headphones, BuildContext context, ThemeData theme, AppLocalizations l) {
    // Verificar si es un modelo compatible con la configuración detallada
    if (headphones is HuaweiHeadphonesBase) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        child: Column(
          children: _buildSettingsWidgets(headphones, context),
        ),
      );
    } else {
      // Mostrar mensaje de dispositivo no compatible con diseño moderno
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Symbols.headset_off,
                  size: 72,
                  weight: 300,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Auriculares no compatibles',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onErrorContainer,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Este dispositivo no es compatible con configuraciones avanzadas.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onErrorContainer.withValues(alpha: 0.8),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                icon: const Icon(Symbols.home),
                label: const Text('Volver al inicio'),
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms).scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.0, 1.0),
            duration: 500.ms,
            curve: Curves.easeOutBack),
      );
    }
  }

  /// Muestra un diálogo de ayuda con información sobre la configuración
  void _showHelpDialog(BuildContext context, AppLocalizations l) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: theme.colorScheme.surface,
        elevation: 3,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Symbols.help_outline,
                color: theme.colorScheme.primary,
                size: 24,
                weight: 300,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Configuración de auriculares',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'En esta sección puedes personalizar el comportamiento de tus auriculares:',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildHelpItem(
                  context,
                  icon: Symbols.play_pause,
                  title: 'Pausa automática',
                  description: 'Configura si los auriculares pausan la música al quitártelos.',
                ),
                const SizedBox(height: 16),
                _buildHelpItem(
                  context,
                  icon: Symbols.touch_app,
                  title: 'Doble toque',
                  description:
                      'Personaliza la acción que se realiza al tocar dos veces cada auricular.',
                ),
                const SizedBox(height: 16),
                _buildHelpItem(
                  context,
                  icon: Symbols.pan_tool,
                  title: 'Mantener pulsado',
                  description: 'Configura qué ocurre al mantener pulsado cada auricular.',
                ),
              ],
            ).animate().fadeIn(duration: 400.ms),
          ),
        ),
        actions: [
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Symbols.check_circle),
            label: const Text('Entendido'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 22,
              weight: 300,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
