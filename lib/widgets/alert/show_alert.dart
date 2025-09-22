import 'package:flutter/material.dart';

class ShowAlert {
  BuildContext context;
  ShowAlert(this.context);

  alert({required Widget child}) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: child,
      ),
    );
  }
}
