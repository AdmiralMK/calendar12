/// Сервис для инициализации и работы с базой данных Isar.
library;

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/settings.dart';

class IsarService {
  static late Isar _isar;

  /// Инициализация базы данных
  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [SettingsSchema],
      directory: dir.path,
    );
  }

  /// Получение экземпляра Isar
  static Isar get instance => _isar;

  /// Получение настроек
  static Future<Settings> getSettings() async {
    return await _isar.settings.get(0) ?? Settings();
  }

  /// Сохранение настроек
  static Future<void> saveSettings(Settings settings) async {
    await _isar.writeTxn(() async {
      await _isar.settings.put(settings);
    });
  }
}