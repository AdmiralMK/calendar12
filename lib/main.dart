// Точка входа в приложение. Инициализация провайдеров.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/calendar_provider.dart';
import 'providers/theme_provider.dart';
import 'ui/screens/home_screen.dart';
import 'ui/themes/app_theme.dart';

void main() async {
  // Обязательная инициализация биндингов Flutter
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const Calendar12App());
}

class Calendar12App extends StatelessWidget {
  const Calendar12App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Провайдер темы (загружает данные из SharedPreferences)
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..loadTheme(),
        ),
        // Провайдер календаря (год)
        ChangeNotifierProvider(
          create: (_) => CalendarProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Календарь12',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}