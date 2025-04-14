import 'package:flutter/material.dart';

import '../theme/dimensions.dart';

class ListTileCheckbox extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const ListTileCheckbox({
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
        child: Checkbox(
          value: value,
          onChanged: onChanged != null ? (_) {} : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.spacing4),
          ),
          side: BorderSide(color: theme.colorScheme.outline, width: 1.5),
        ),
      ),
    );
  }
}
