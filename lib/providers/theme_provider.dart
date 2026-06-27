// Провайдер для управления темой приложения и сохранения выбора в SharedPreferences.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  // Ключ для хранения в SharedPreferences
  static const String _themeModeKey = 'themeModeIndex';

  ThemeMode get themeMode => _themeMode;

  /// Загрузка темы из SharedPreferences при старте
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeModeKey) ?? 0;
    
    // Безопасная проверка индекса
    if (themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeIndex];
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  /// Переключение темы по кругу: Система -> Светлая -> Темная -> Система
  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case ThemeMode.system:
        _themeMode = ThemeMode.light;
        break;
      case ThemeMode.light:
        _themeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _themeMode = ThemeMode.system;
        break;
    }
    
    // Сохраняем в SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, _themeMode.index);
    
    notifyListeners();
  }

  /// Получение иконки для текущей темы
  IconData get themeIcon {
    switch (_themeMode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.brightness_high;
      case ThemeMode.dark:
        return Icons.brightness_2;
    }
  }
}