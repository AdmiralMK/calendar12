/// Файл для хранения всех фиксированных констант приложения.
library;

class AppConstants {
  AppConstants._(); // Запрещаем создание экземпляров

  /// Минимальный год для выбора
  static const int minYear = 1950;
  
  /// Максимальный год для выбора
  static const int maxYear = 2050;
  
  /// Количество месяцев в году
  static const int monthsInYear = 12;
  
  /// Количество колонок в сетке календаря
  static const int gridColumns = 3;
  
  /// Соотношение сторон для карточки месяца (ширина / высота)
  /// Увеличено для лучшего заполнения пространства
  static const double monthCardAspectRatio = 0.82;
}