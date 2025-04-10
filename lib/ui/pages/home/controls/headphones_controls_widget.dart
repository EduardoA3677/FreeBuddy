import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../headphones/framework/anc.dart';
import '../../../../headphones/framework/bluetooth_headphones.dart';
import '../../../../headphones/framework/headphones_settings.dart';
import '../../../../headphones/framework/lrc_battery.dart';
import '../../../../logger.dart';
import '../../../theme/layouts.dart';
import 'anc_card.dart';
import 'battery_card.dart';

/// Main whole-screen widget with controls for headphones
///
/// It contains battery, anc buttons, button to settings etc - just give it
/// the [headphones] and all done ☺
///
/// ...in fact, it is built so simple that you can freely hot-swap the
/// headphones object - for example, if they disconnect for a moment,
/// you can give it [HeadphonesMockNever] object, and previous values will stay
/// because it won't override them
class HeadphonesControlsWidget extends StatelessWidget {
  final BluetoothHeadphones headphones;

  const HeadphonesControlsWidget({super.key, required this.headphones});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final windowSize = WindowSizeClass.of(context);
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    // Envolver todo en un SafeArea y un try-catch para capturar errores de renderizado
    return SafeArea(
      child: Builder(
        builder: (context) {
          try {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(12.0) + EdgeInsets.only(bottom: bottomPadding),
              child: Column(
                children: [
                  _buildHeader(textTheme),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildMainContent(windowSize),
                  ),
                  if (headphones is HeadphonesSettings) ...[
                    const SizedBox(height: 16),
                    _buildSettingsButton(context),
                  ],
                ],
              ),
            );
          } catch (e, stackTrace) {
            // Si hay un error al renderizar, mostrar un mensaje de error
            log(LogLevel.error, "Error al renderizar HeadphonesControlsWidget",
                error: e, stackTrace: stackTrace);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar controles',
                    style: textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No se pudieron cargar los controles de los auriculares',
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    onPressed: () {
                      // Forzar reconstrucción del widget
                      (context as Element).markNeedsBuild();
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    return Text(
      'Headphones Controls',
      style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildMainContent(WindowSizeClass windowSize) {
    // Registrar información de depuración sobre los auriculares
    log(LogLevel.debug,
        "Construyendo contenido principal para auriculares: ${headphones.runtimeType}");

    // Lista para almacenar los widgets que se mostrarán
    final contentWidgets = <Widget>[];

    // Intentar añadir el widget de batería si está disponible
    try {
      if (headphones is LRCBattery) {
        log(LogLevel.debug, "Auriculares soportan LRCBattery, añadiendo BatteryCard");
        contentWidgets.add(BatteryCard(headphones as LRCBattery));
      } else {
        log(LogLevel.debug, "Auriculares no soportan LRCBattery");
      }
    } catch (e, stackTrace) {
      log(LogLevel.error, "Error al cargar BatteryCard", error: e, stackTrace: stackTrace);
    }

    // Intentar añadir el widget de ANC si está disponible
    try {
      if (headphones is Anc) {
        contentWidgets.add(AncCard(headphones as Anc));
      }
    } catch (e) {
      debugPrint("Error al cargar AncCard: $e");
    }

    // Si no hay widgets para mostrar, mostrar un mensaje de error
    if (contentWidgets.isEmpty) {
      return _buildErrorContent("No se pudieron cargar los controles",
          "No se encontraron funciones compatibles en tus auriculares.");
    }

    return ListView(
      children: contentWidgets,
    );
  }

  // Método para construir contenido de error
  Widget _buildErrorContent(String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.headphones_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => GoRouter.of(context).push('/settings'),
      icon: const Icon(Icons.settings),
      label: const Text('Settings'),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
