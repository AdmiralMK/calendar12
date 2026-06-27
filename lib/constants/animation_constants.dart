// Константы для анимации переворота плиток календаря.
import 'dart:math';

class AnimationConstants {
  // Общая длительность анимации волны (все плитки)
  static const Duration totalAnimationDuration = Duration(milliseconds: 29000);
  
  // Задержка между началом анимации соседних плиток (в процентах от общей длительности)
  static const double staggerDelay = 0.03; // 6% между плитками
  
  // Длительность анимации одной плитки (в процентах от общей длительности)
  static const double tileAnimationDuration = 0.30; // 60% для каждой плитки
  
  // Максимальный угол поворота (в радианах)
  static const double maxRotationAngle = pi / 2; // 90 градусов
  
  // Минимальная прозрачность при максимальном повороте
  static const double minOpacity = 0.2;
  
  // Максимальная прозрачность (нормальное состояние)
  static const double maxOpacity = 1.0;
}