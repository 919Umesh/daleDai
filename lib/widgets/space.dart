import 'package:flutter/material.dart';

Widget horizantalSpace(double? width) {
  return SizedBox(
    width: width ?? 5.0,
    height: 0.0,
  );
}

Widget verticalSpace(double? height) {
  return SizedBox(
    height: height ?? 5.0,
    width: 0.0,
  );
}
