import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyTimeConverter {
  static getTimeStamp() {
    debugPrint("TIMESTAMP ${DateTime.now().millisecondsSinceEpoch}");
    return DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10);
  }

  static convertDateToTimeStamp({required String date}) {
    DateFormat dateFormat = DateFormat('yyyy/MM/dd');
    DateTime dateTime = dateFormat.parse(date);

    int timestamp = dateTime.millisecondsSinceEpoch;
    return timestamp.toString().substring(0, 10);
  }
}
