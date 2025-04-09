import 'package:flutter/material.dart';

import '../../../../headphones/framework/headphones_info.dart';

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
            child: StreamBuilder(
              stream: modelInfo.imageAssetPath,
              builder: (_, snap) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: snap.data != null
                    ? Image.asset(
                        snap.data!,
                        key: ValueKey(snap.data),
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                      )
                    : Container(
                        key: const ValueKey('placeholder'),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withAlpha((0.3 * 255).round()),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
