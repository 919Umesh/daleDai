import 'package:flutter/material.dart';

class TableDataWidget extends StatelessWidget {
  final Widget child;
  final void Function()? onTap;
  final Color? color;
  const TableDataWidget(
      {super.key, required this.child, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.5),
      color: color ?? Colors.transparent,
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 10.0,
              ),
              child: child,
            ),
          ),
          Container(
            height: 0.5,
            color: Colors.black,
          )
        ],
      ),
    );
  }
}
