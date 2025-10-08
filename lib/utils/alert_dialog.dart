import 'package:flutter/material.dart';

class ShowDialog {
  ShowDialog({required this.context});
  BuildContext context;
  dialog({required Widget child}) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: child,
      ),
    );
  }
}
