import 'package:flutter/material.dart';

import '../constants/text_style.dart';
import '../themes/colors.dart';

class SaveButton extends StatelessWidget {
  final String buttonName;
  final void Function() onClick;
  const SaveButton({
    super.key,
    required this.buttonName,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: primaryColor,
      child: InkWell(
        onTap: () {
          onClick();
        },
        child: Container(
          width: 200,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              buttonName,
              textAlign: TextAlign.center,
              style: cardTextStyleHeader,
            ),
          ),
        ),
      ),
    );
  }
}

class CancleButton extends StatelessWidget {
  final String buttonName;
  final void Function() onClick;
  const CancleButton({
    super.key,
    required this.buttonName,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: errorColor,
      child: InkWell(
        onTap: () {
          onClick();
        },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            buttonName,
            textAlign: TextAlign.center,
            style: cardTextStyleHeader ,
          ),
        ),
      ),
    );
  }
}
