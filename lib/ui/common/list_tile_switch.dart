import 'package:flutter/material.dart';

import '../theme/dimensions.dart';

class ListTileSwitch extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const ListTileSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      title: title,
      subtitle: subtitle,
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      contentPadding: AppDimensions.listTilePadding,
      trailing: IgnorePointer(
        child: Switch(
          value: value,
          onChanged: onChanged != null ? (_) {} : null,
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.outline,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
    );
  }
}
