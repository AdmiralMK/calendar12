/// Настройки светлой и темной тем приложения.
library;

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  /// Светлая тема
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: Colors.blue,
      scaffoldBackgroundColor: Colors.grey[50],
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    );
  }

  /// Темная тема
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: Colors.blue,
      scaffoldBackgroundColor: Colors.grey[900],
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    );
  }
}