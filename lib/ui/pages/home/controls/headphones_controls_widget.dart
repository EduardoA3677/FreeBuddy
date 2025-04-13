import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../headphones/framework/anc.dart';
import '../../../../headphones/framework/lrc_battery.dart';
import '../../../../logger.dart';
import '../../../../headphones/framework/bluetooth_headphones.dart';
import '../../../../headphones/huawei/huawei_headphones_base.dart';
import '../../../../headphones/huawei/huawei_headphones_impl.dart';
import 'anc_card.dart';
import 'battery_card.dart';
import 'headphones_image.dart';

class HeadphonesControlsWidget extends StatelessWidget {
  final BluetoothHeadphones headphones;

  const HeadphonesControlsWidget({super.key, required this.headphones});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    // Inicializo el nombre y la imagen del dispositivo.
    String deviceName = l.unknownDevice;
    Widget? deviceImage;

    if (headphones is HuaweiHeadphonesBase && headphones is HuaweiHeadphonesImpl) {
      final modelDef = (headphones as HuaweiHeadphonesImpl).modelDefinition;
      deviceName = '${modelDef.vendor} ${modelDef.name}'; // Obtengo el nombre del dispositivo
      deviceImage = HeadphonesImage(headphones); // Imagen del dispositivo
    }

    try {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título: Nombre del dispositivo (HuaweiModelDefinition)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              deviceName,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Imagen del dispositivo
          if (deviceImage != null)
            Center(
              child: SizedBox(
                width: 180,
                height: 180,
                child: deviceImage,
              ),
            ),
          const SizedBox(height: 24),
          // Controles adicionales (ejemplo: ANC y batería)
          if (headphones is LRCBattery) BatteryCard(headphones as LRCBattery),
          if (headphones is Anc) const SizedBox(height: 16),
          if (headphones is Anc) AncCard(headphones as Anc),
        ],
      );
    } catch (e, stackTrace) {
      log(LogLevel.error, "Error building HeadphonesControlsWidget", error: e, stackTrace: stackTrace);
      return Center(
        child: Text(
          l.headphonesControlError,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      );
    }
  }
}
