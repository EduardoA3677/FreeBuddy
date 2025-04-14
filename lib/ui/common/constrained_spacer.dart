import 'package:flutter/widgets.dart';

import '../theme/dimensions.dart';

/// Un espaciador flexible con restricciones que puede ser usado en layouts
/// para ocupar espacio de forma controlada
class ConstrainedSpacer extends StatelessWidget {
  final BoxConstraints constraints;
  final int flex;

  /// Crea un espaciador con restricciones predefinidas
  const ConstrainedSpacer(
      {super.key, required this.constraints, this.flex = 1});

  /// Crea un espaciador con altura fija
  static ConstrainedSpacer height(double height, {int flex = 1}) {
    return ConstrainedSpacer(
      constraints: BoxConstraints(minHeight: height, maxHeight: height),
      flex: flex,
    );
  }

  /// Crea un espaciador con ancho fijo
  static ConstrainedSpacer width(double width, {int flex = 1}) {
    return ConstrainedSpacer(
      constraints: BoxConstraints(minWidth: width, maxWidth: width),
      flex: flex,
    );
  }

  /// Crea un espaciador con dimensión estándar pequeña
  static ConstrainedSpacer small({bool vertical = true, int flex = 1}) {
    return vertical
        ? height(AppDimensions.spacing8, flex: flex)
        : width(AppDimensions.spacing8, flex: flex);
  }

  /// Crea un espaciador con dimensión estándar mediana
  static ConstrainedSpacer medium({bool vertical = true, int flex = 1}) {
    return vertical
        ? height(AppDimensions.spacing16, flex: flex)
        : width(AppDimensions.spacing16, flex: flex);
  }

  /// Crea un espaciador con dimensión estándar grande
  static ConstrainedSpacer large({bool vertical = true, int flex = 1}) {
    return vertical
        ? height(AppDimensions.spacing24, flex: flex)
        : width(AppDimensions.spacing24, flex: flex);
  }

  @override
  Widget build(BuildContext context) =>
      Flexible(flex: flex, child: Container(constraints: constraints));
}
