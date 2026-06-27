/// Провайдер для управления текущим выбранным годом.
library;

import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class CalendarProvider extends ChangeNotifier {
  int _currentYear = DateTime.now().year;

  int get currentYear => _currentYear;

  /// Установить конкретный год
  void setYear(int year) {
    if (year >= AppConstants.minYear && year <= AppConstants.maxYear) {
      _currentYear = year;
      notifyListeners();
    }
  }

  /// Уменьшить год на 1
  void previousYear() {
    if (_currentYear > AppConstants.minYear) {
      _currentYear--;
      notifyListeners();
    }
  }

  /// Увеличить год на 1
  void nextYear() {
    if (_currentYear < AppConstants.maxYear) {
      _currentYear++;
      notifyListeners();
    }
  }
}