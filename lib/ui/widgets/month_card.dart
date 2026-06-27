// Виджет одной карточки месяца (название + сетка дней).
// Адаптируется под доступное пространство.
import 'package:flutter/material.dart';
import '../../localization/app_strings.dart';

class MonthCard extends StatelessWidget {
  final int month; // 1-12
  final int year;

  const MonthCard({super.key, required this.month, required this.year});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    
    // Получаем количество дней в месяце
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // Получаем день недели первого числа (0 = Пн, 6 = Вс)
    // В Dart DateTime.weekday: 1=Пн, 7=Вс. Приводим к 0-6.
    final firstWeekday = DateTime(year, month, 1).weekday - 1; 

    return Card(
      margin: const EdgeInsets.all(2.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
        child: Column(
          children: [
            // Заголовок месяца
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
            
            // Дни недели с горизонтальной линией
            _buildWeekDaysRow(theme),
            
            // Сетка дней
            Expanded(
              child: _buildDaysGrid(daysInMonth, firstWeekday, theme, today),
            ),
          ],
        ),
      ),
    );
  }

  /// Отрисовка строки с днями недели и горизонтальной линией
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
        // Горизонтальная линия (УМЕНЬШЕНО с 1.5 до 0.5)
        Container(
          margin: const EdgeInsets.symmetric(vertical: 2.0),
          height: 0.5,
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  /// Отрисовка сетки дней месяца с вертикальной линией
  Widget _buildDaysGrid(int daysInMonth, int firstWeekday, ThemeData theme, DateTime today) {
    // Общее количество ячеек (дни + пустые в начале)
    final totalCells = daysInMonth + firstWeekday;
    // Количество строк (максимум 6)
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
              decoration: isToday ? BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ) : null,
              child: Text(
                dayNumber.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isToday 
                      ? theme.colorScheme.onPrimaryContainer
                      : (isWeekend ? theme.colorScheme.error : theme.colorScheme.onSurface),
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            );
          },
        ),
        // Вертикальная линия между пятницей и субботой (УМЕНЬШЕНО с 1.5 до 0.5)
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Container(),
              ),
              Container(
                width: 0.5,
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              Expanded(
                flex: 2,
                child: Container(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}