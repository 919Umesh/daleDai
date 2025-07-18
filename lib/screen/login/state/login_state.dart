import 'package:flutter/material.dart';
import 'package:omspos/utils/custom_log.dart';

class LoginState extends ChangeNotifier {
  LoginState();

  late BuildContext _context;
  set getContext(BuildContext value) {
    _context = value;
    _initialize();
  }

  _initialize() {
    CustomLog.successLog(value: '------------LoginState--------------');
    CustomLog.successLog(value: 'Login State has been initalize');
  }
}
