import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../headphones/framework/sound_quality.dart';
import '../../../../headphones/huawei/huawei_headphones_base.dart';
import '../../../theme/dimensions.dart';

/// Sección de calidad de sonido
class SoundQualitySection extends StatelessWidget {
  final HuaweiHeadphonesBase headphones;

  const SoundQualitySection(this.headphones, {super.key});

  static const soundQualityOptions = [
    _SoundQualityOption(
        mode: SoundQualityMode.connectivity,
        label: 'Priorizar conexión',
        description: 'Mejor estabilidad de conexión',
        icon: Symbols.network_wifi_rounded),
    _SoundQualityOption(
        mode: SoundQualityMode.quality,
        label: 'Priorizar calidad',
        description: 'Mejor calidad de audio',
        icon: Symbols.high_quality_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SoundQualityMode>(
      stream: headphones.soundQualityMode,
      initialData: SoundQualityMode.connectivity,
      builder: _soundQualitySelectorBuilder,
    );
  }

  Widget _soundQualitySelectorBuilder(
      BuildContext context, AsyncSnapshot<SoundQualityMode> snapshot) {
    final currentMode = snapshot.data ?? SoundQualityMode.connectivity;
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppDimensions.spacing8),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.spacing8,
                horizontal: AppDimensions.spacing4,
              ),
              child: Column(
                children: soundQualityOptions
                    .map(
                      (option) => _soundQualityOptionTile(
                        context,
                        option: option,
                        selected: currentMode == option.mode,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing8),
            child: Text(
              'Elige entre priorizar la calidad de audio o la estabilidad de la conexión según tus necesidades.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _soundQualityOptionTile(BuildContext context,
      {required _SoundQualityOption option, required bool selected}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colorScheme.primaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: InkWell(
        onTap: () => _setSoundQualityMode(option.mode),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing16,
            vertical: AppDimensions.spacing12,
          ),
          child: Row(
            children: [
              Icon(
                option.icon,
                color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                size: AppDimensions.iconMedium,
              ),
              const SizedBox(width: AppDimensions.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                selected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: selected
                                ? colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
                                : colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: colorScheme.primary,
                  size: AppDimensions.iconMedium,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _setSoundQualityMode(SoundQualityMode mode) {
    headphones.setSoundQualityMode(mode);
  }
}

class _SoundQualityOption {
  final SoundQualityMode mode;
  final String label;
  final String description;
  final IconData icon;

  const _SoundQualityOption(
      {required this.mode, required this.label, required this.description, required this.icon});
}
