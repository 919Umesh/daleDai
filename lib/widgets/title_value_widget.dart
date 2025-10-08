import 'package:flutter/material.dart';

import '../themes/themes.dart';
import 'container_decoration.dart';

class TitleValueWidget extends StatelessWidget {
  final String title, value;

  const TitleValueWidget({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ContainerDecoration.decoration(),
      margin: const EdgeInsets.symmetric(vertical: 3.0),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(children: [
        Expanded(
          child: Text(
            title,
            style: textFormTitleStyle,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.center,
          ),
        ),
      ]),
    );
  }
}

class PDCTitleValueWidget extends StatelessWidget {
  final String title, value;
  const PDCTitleValueWidget({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ContainerDecoration.decoration(bColor: Colors.white),
      margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: textFormTitleStyle,
            textAlign: TextAlign.start,
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.start,
          ),
        ),
      ]),
    );
  }
}
