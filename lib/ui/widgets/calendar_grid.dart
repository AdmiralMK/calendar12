// Виджет сетки календаря с управлением анимацией.
import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import 'month_card.dart';

class CalendarGrid extends StatefulWidget {
  final int year;
  final AnimationController flipController;
  final List<Animation<double>> tileAnimations;

  const CalendarGrid({
    super.key,
    required this.year,
    required this.flipController,
    required this.tileAnimations,
  });

  @override
  State<CalendarGrid> createState() => _CalendarGridState();
}

class _CalendarGridState extends State<CalendarGrid> {
  @override
  void didUpdateWidget(CalendarGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Если год изменился - запускаем анимацию
    if (oldWidget.year != widget.year) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.flipController
            ..reset()
            ..forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppConstants.gridColumns,
          childAspectRatio: AppConstants.monthCardAspectRatio,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: AppConstants.monthsInYear,
        itemBuilder: (context, index) {
          return MonthCard(
            month: index + 1,
            year: widget.year, // ✅ Только один параметр year
            flipAnimation: widget.tileAnimations[index],
          );
        },
      ),
    );
  }
}