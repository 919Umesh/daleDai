import 'package:flutter/material.dart';

class ContainerDecoration {
  static BoxDecoration decoration({
    double? height,
    double? width,
    Color? bColor,
    Color? color,
    BorderRadiusGeometry? borderRadius,
  }) {
    return BoxDecoration(
      color: color,
      border: bColor == null ? null : Border.all(color: bColor),
      borderRadius: borderRadius ?? BorderRadius.circular(5.0),
    );
  }
}
