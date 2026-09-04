import 'package:flutter/material.dart';

class CustomLog {
  static void log({required dynamic value}) {
    debugPrint("\x1B[37m $value \x1B[0m");
  }

  static void errorLog({required dynamic value}) {
    debugPrint("\x1B[31m $value \x1B[0m");
  }

  static void warningLog({required dynamic value}) {
    debugPrint("\x1B[33m $value \x1B[0m");
  }

  static void successLog({required dynamic value}) {
    debugPrint("\x1B[32m $value \x1B[0m");
  }

  static void actionLog({required dynamic value}) {
    debugPrint("\x1B[36m $value \x1B[0m");
  }
}
