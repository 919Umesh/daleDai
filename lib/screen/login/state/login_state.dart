import 'package:flutter/material.dart';

class LoginState extends ChangeNotifier {
  LoginState();

  late BuildContext _context;
  set getContext(BuildContext value) {
    _context = value;
    _initialize();
  }

  _initialize() {
    debugPrint('Login Has been initalized');
  }
}
