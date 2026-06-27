/// Файл для хранения всех текстовых строк и наименований интерфейса.
library;

class AppStrings {
  AppStrings._();

  /// Название приложения
  static const String appTitle = 'Календарь12';

  /// Названия месяцев
  static const List<String> monthNames = [
    'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
    'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
  ];

  /// Названия дней недели (короткие)
  static const List<String> weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  /// Подсказки для кнопок переключения темы
  static const String themeSystem = 'Системная';
  static const String themeLight = 'Светлая';
  static const String themeDark = 'Темная';

  /// Текст для тултипа кнопки смены темы
  static const String changeThemeTooltip = 'Сменить тему';
}