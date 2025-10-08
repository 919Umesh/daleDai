import 'package:flutter/material.dart';

import '../themes/colors.dart';

class GredientContainer extends StatelessWidget {
  final Widget child;
  final bool? reverseGredient;
  const GredientContainer(
      {super.key, required this.child, this.reverseGredient = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: reverseGredient == false
              ? [Colors.white, primaryColor]
              : [primaryColor, Colors.white],
        ),
      ),
      child: child,
    );
  }
}
