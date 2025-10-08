import 'package:flutter/material.dart';

import '../themes/colors.dart';

class CustomDivider extends StatelessWidget {
  final double? height, width, horizontalMargin, verticalMargin;
  final Color? color;

  const CustomDivider({
    Key? key,
    this.height,
    this.width,
    this.color,
    this.horizontalMargin,
    this.verticalMargin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 1,
      width: width,
      margin: EdgeInsets.symmetric(
        vertical: verticalMargin ?? 5.0,
        horizontal: horizontalMargin ?? 0.0,
      ),
      color: color ?? borderColor,
    );
  }
}

class CustomDottedDivider extends StatelessWidget {
  const CustomDottedDivider({Key? key, this.height = 1, this.color})
      : super(key: key);
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 2.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();

        ///
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,

          ///
          children: List.generate(dashCount, (_) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 3.0),
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color ?? borderColor),
              ),
            );
          }),
        );
      },
    );
  }
}
