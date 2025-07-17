import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../themes/colors.dart';


class ShowToast {
  static showToast({required String msg, required Color backgroundColor}) {
    return Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
    );
  }

  static successToast({required String msg}) {
    return Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: successColor,
      textColor: Colors.white,
    );
  }

  static errorToast({required String msg}) {
    return Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: errorColor,
      textColor: Colors.white,
    );
  }
}
