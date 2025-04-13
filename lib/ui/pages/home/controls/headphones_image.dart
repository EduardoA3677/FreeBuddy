import 'package:flutter/material.dart';
import '../../../../headphones/framework/headphones_info.dart';
import '../../../theme/dimensions.dart';

class HeadphonesImage extends StatelessWidget {
  final HeadphonesModelInfo modelInfo;

  const HeadphonesImage(this.modelInfo, {super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final padding = maxSize * 0.15; // 15% padding

        return Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: maxSize,
              maxHeight: maxSize,
            ),
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: AppDimensions.spacing12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: StreamBuilder<String?>(
              stream: modelInfo.imageAssetPath,
              builder: (_, snap) {
                final imagePath = snap.data;

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: imagePath != null
                      ? Image.asset(
                          imagePath,
                          key: ValueKey(imagePath),
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        )
                      : _buildPlaceholder(context),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: const ValueKey('placeholder'),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Center(
        child: Icon(
          Icons.headphones, // Placeholder icon for image
          color: theme.colorScheme.onSurfaceVariant,
          size: AppDimensions.iconXLarge,
        ),
      ),
    );
  }
}
