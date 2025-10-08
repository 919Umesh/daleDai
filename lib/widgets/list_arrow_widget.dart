import 'package:flutter/material.dart';

import '../themes/themes.dart';
import 'space.dart';

class ArrowListWidget extends StatelessWidget {
  final Widget child;
  const ArrowListWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Icon(
            Icons.arrow_forward_ios_sharp,
            size: 18.0,
            color: hintColor,
          ),
        ),
        horizantalSpace(8.0),
        Expanded(flex: 4, child: child),
      ],
    );
  }
}
