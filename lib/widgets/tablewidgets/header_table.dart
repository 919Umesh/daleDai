import 'package:flutter/material.dart';


import '../../themes/colors.dart';
import '../container_decoration.dart';

class TableHeaderWidget extends StatelessWidget {
  final Widget child;
  final Color? color;
  const TableHeaderWidget({super.key, required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ContainerDecoration.decoration(
        color: color ?? primaryColor,
        bColor: color ?? primaryColor,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: child,
      ),
    );
  }
}
