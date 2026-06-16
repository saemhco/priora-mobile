import 'package:flutter/material.dart';

class PatientNavigationController extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void changeIndex(int newIndex) {
    if (_currentIndex == newIndex) return;
    _currentIndex = newIndex;
    notifyListeners();
  }
}
