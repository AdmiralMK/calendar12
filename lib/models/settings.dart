/// Модель данных для Isar. Хранит настройки пользователя (тему).
library;

import 'package:isar/isar.dart';

part 'settings.g.dart'; // Файл генерируется build_runner

@collection
class Settings {
  Id id = 0; // В Isar ID должен быть типа Id (int)
  
  /// Индекс темы: 0 - системная, 1 - светлая, 2 - темная
  int themeModeIndex = 0; 
}