// Провайдер для управления текущим выбранным годом.
import 'package:flutter/material.dart';

class CalendarProvider extends ChangeNotifier {
  int _currentYear = DateTime.now().year;

  int get currentYear => _currentYear;

  void setYear(int year) {
    if (_currentYear != year) {
      _currentYear = year;
      notifyListeners();
    }
  }

  void nextYear() {
    if (_currentYear < 2070) {
      _currentYear++;
      notifyListeners();
    }
  }

  void previousYear() {
    if (_currentYear > 1900) {
      _currentYear--;
      notifyListeners();
    }
  }
}