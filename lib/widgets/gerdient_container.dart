import 'package:flutter/material.dart';

import '../themes/colors.dart';

class GredientContainer extends StatelessWidget {
  final Widget child;
  final bool? reverseGredient;
  const GredientContainer(
      {super.key, required this.child, this.reverseGredient = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: reverseGredient == false
              ? [scheme.surface, primaryColor]
              : [primaryColor, scheme.surface],
        ),
      ),
      child: child,
    );
  }
}
