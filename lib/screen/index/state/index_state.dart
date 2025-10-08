import 'package:flutter/material.dart';

class IndexState extends ChangeNotifier {
  int _currentIndex = 0;
  IconData _fabIcon = Icons.home;

  final List<IconData> _icons = [
    Icons.home,
    Icons.list_alt,
    Icons.favorite,
    Icons.person,
  ];

  int get currentIndex => _currentIndex;
  IconData get fabIcon => _fabIcon;
  List<IconData> get icons => _icons;

  void updateIndex(int index) {
    _currentIndex = index;
    _fabIcon = _icons[index];
    notifyListeners();
  }
}