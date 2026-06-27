/// Провайдер для управления темой приложения и сохранения выбора в БД.
library;

import 'package:flutter/material.dart';
import '../database/isar_service.dart';
import '../models/settings.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// Загрузка темы из БД при старте
  Future<void> loadTheme() async {
    final settings = await IsarService.getSettings();
    _themeMode = ThemeMode.values[settings.themeModeIndex];
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
    
    // Сохраняем в БД
    final settings = Settings()..themeModeIndex = _themeMode.index;
    await IsarService.saveSettings(settings);
    
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