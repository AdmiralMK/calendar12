// Виджет одной карточки месяца с анимацией переворота.
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../localization/app_strings.dart';

class MonthCard extends StatelessWidget {
  final int month;
  final int year;
  final Animation<double> flipAnimation;
  final double animationDelay;

  const MonthCard({
    super.key,
    required this.month,
    required this.year,
    required this.flipAnimation,
    this.animationDelay = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday - 1;

    return AnimatedBuilder(
      animation: flipAnimation,
      builder: (context, child) {
        // Получаем текущее значение анимации (0.0 - 1.0)
        final animationValue = flipAnimation.value;
        
        // Если анимация не активна или завершена
if (animationValue < 0.01 || animationValue > 0.99) {
  return _buildCardContent(theme, today, daysInMonth, firstWeekday);
}
        
        // Вычисляем staggered значение для этой плитки
        final start = animationDelay;
        final end = (animationDelay + 0.4).clamp(0.0, 1.0);
        
        // Нормализуем: 0.0 когда анимация ещё не дошла до этой плитки,
        // 1.0 когда анимация полностью прошла
        final staggeredValue = ((animationValue - start) / (end - start)).clamp(0.0, 1.0);
        
        // Создаём эффект переворота: 0→1→0
        final flipProgress = staggeredValue < 0.5 
            ? staggeredValue * 2 
            : (1 - staggeredValue) * 2;
        
        // Угол наклона: 0° → 90° → 0°
        final angle = flipProgress * (math.pi / 2);
        
        // Прозрачность: 1.0 → 0.3 → 1.0
        final opacity = 1.0 - 0.7 * flipProgress;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationX(angle),
          child: Opacity(
            opacity: opacity,
            child: _buildCardContent(theme, today, daysInMonth, firstWeekday),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(
    ThemeData theme,
    DateTime today,
    int daysInMonth,
    int firstWeekday,
  ) {
    return Card(
      margin: const EdgeInsets.all(2.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
        child: Column(
          children: [
            Text(
              AppStrings.monthNames[month - 1],
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            _buildWeekDaysRow(theme),
            Expanded(
              child: _buildDaysGrid(daysInMonth, firstWeekday, theme, today),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekDaysRow(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: AppStrings.weekDays.map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 2.0),
          height: 0.5,
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _buildDaysGrid(
    int daysInMonth,
    int firstWeekday,
    ThemeData theme,
    DateTime today,
  ) {
    final totalCells = daysInMonth + firstWeekday;
    final rows = (totalCells / 7).ceil();

    return Stack(
      children: [
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 0.0,
            crossAxisSpacing: 0.0,
          ),
          itemCount: rows * 7,
          itemBuilder: (context, index) {
            final dayNumber = index - firstWeekday + 1;
            if (index < firstWeekday || dayNumber > daysInMonth) {
              return const SizedBox.shrink();
            }
            final isWeekend = (index % 7 == 5 || index % 7 == 6);
            final isToday = (today.year == year &&
                today.month == month &&
                today.day == dayNumber);

            return Container(
              alignment: Alignment.center,
              decoration: isToday
                  ? BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    )
                  : null,
              child: Text(
                dayNumber.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isToday
                      ? theme.colorScheme.onPrimaryContainer
                      : (isWeekend
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurface),
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            );
          },
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: Row(
            children: [
              Expanded(flex: 5, child: Container()),
              Container(
                width: 0.5,
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              Expanded(flex: 2, child: Container()),
            ],
          ),
        ),
      ],
    );
  }
}