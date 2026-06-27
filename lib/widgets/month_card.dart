// Виджет одной карточки месяца с анимацией переворота.
// StatefulWidget для управления переключением года в середине анимации.
import 'package:flutter/material.dart';
import '../../constants/animation_constants.dart';
import '../../localization/app_strings.dart';

class MonthCard extends StatefulWidget {
  final int month;
  final int year;
  final Animation<double> flipAnimation;

  const MonthCard({
    super.key,
    required this.month,
    required this.year,
    required this.flipAnimation,
  });

  @override
  State<MonthCard> createState() => _MonthCardState();
}

class _MonthCardState extends State<MonthCard> {
  late int _displayedYear; // Год, который сейчас отображается
  int? _pendingYear; // Год, который нужно показать после середины анимации

  @override
  void initState() {
    super.initState();
    _displayedYear = widget.year;
    widget.flipAnimation.addListener(_onAnimationUpdate);
  }

  @override
  void didUpdateWidget(MonthCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Если год изменился - сохраняем его как "ожидающий"
    if (oldWidget.year != widget.year) {
      _pendingYear = widget.year;
    }
    
    // Если анимация изменилась - переподписываемся
    if (oldWidget.flipAnimation != widget.flipAnimation) {
      oldWidget.flipAnimation.removeListener(_onAnimationUpdate);
      widget.flipAnimation.addListener(_onAnimationUpdate);
    }
  }

  @override
  void dispose() {
    widget.flipAnimation.removeListener(_onAnimationUpdate);
    super.dispose();
  }

  void _onAnimationUpdate() {
    // Когда анимация достигает середины (90°) и есть ожидающий год - переключаем
    if (widget.flipAnimation.value >= 0.5 && 
        _pendingYear != null && 
        _pendingYear != _displayedYear) {
      final newYear = _pendingYear!;
      _pendingYear = null; // Сначала обнуляем, чтобы избежать повторного вызова
      if (mounted) {
        setState(() {
          _displayedYear = newYear;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();

    return AnimatedBuilder(
      animation: widget.flipAnimation,
      builder: (context, child) {
        final animationValue = widget.flipAnimation.value;
        
        // Создаём эффект переворота: 0→1→0
        final flipProgress = animationValue < 0.5 
            ? animationValue * 2 
            : (1 - animationValue) * 2;
        
        // Угол наклона: 0° → 90° → 0°
        final angle = flipProgress * AnimationConstants.maxRotationAngle;
        
        // Прозрачность: 1.0 → 0.2 → 1.0
        final opacity = AnimationConstants.maxOpacity - 
            (AnimationConstants.maxOpacity - AnimationConstants.minOpacity) * flipProgress;
        
        // Масштабирование: 1.0 → 0.95 → 1.0
        final scale = 1.0 - 0.05 * flipProgress;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..rotateX(angle),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              // ИСПОЛЬЗУЕМ _displayedYear, а не widget.year!
              child: _buildCardContent(theme, today, _displayedYear),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(
    ThemeData theme,
    DateTime today,
    int year,
  ) {
    final daysInMonth = DateTime(year, widget.month + 1, 0).day;
    final firstWeekday = DateTime(year, widget.month, 1).weekday - 1;

    return Card(
      margin: const EdgeInsets.all(2.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
        child: Column(
          children: [
            Text(
              AppStrings.monthNames[widget.month - 1],
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
              child: _buildDaysGrid(daysInMonth, firstWeekday, theme, today, year),
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
    int year,
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
                today.month == widget.month &&
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