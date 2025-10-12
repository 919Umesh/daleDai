import 'package:flutter/material.dart';

class IndexState extends ChangeNotifier {
  int _currentIndex = 0;
  IconData _fabIcon = Icons.home;
  bool _isBottomBarVisible = true;

  final List<IconData> _icons = [
    Icons.home,
    Icons.list_alt,
    Icons.favorite,
    Icons.person,
  ];

  int get currentIndex => _currentIndex;
  IconData get fabIcon => _fabIcon;
  bool get isBottomBarVisible => _isBottomBarVisible;
  List<IconData> get icons => _icons;

  void updateIndex(int index) {
    _currentIndex = index;
    _fabIcon = _icons[index];
    if (!_isBottomBarVisible) {
      _isBottomBarVisible = true;
    }
    notifyListeners();
  }

  void toggleBottomBarVisibility(bool visible) {
    if (_isBottomBarVisible != visible) {
      _isBottomBarVisible = visible;
      notifyListeners();
    }
  }

  void showBottomBar() {
    if (!_isBottomBarVisible) {
      _isBottomBarVisible = true;
      notifyListeners();
    }
  }

  void hideBottomBar() {
    if (_isBottomBarVisible) {
      _isBottomBarVisible = false;
      notifyListeners();
    }
  }
}
