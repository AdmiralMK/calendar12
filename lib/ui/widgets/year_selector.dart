// Виджет селектора года с кнопками переключения и сеткой годов.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/calendar_provider.dart';

class YearSelector extends StatelessWidget {
  const YearSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Кнопка "Минус"
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  icon: const Icon(Icons.remove, size: 16),
                  onPressed: provider.currentYear > AppConstants.minYear 
                      ? provider.previousYear 
                      : null,
                  tooltip: 'Предыдущий год',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              
              // Кнопка выбора года (открывает диалог с сеткой)
              SizedBox(
                width: 75,
                height: 32,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showYearGridDialog(context, provider),
                    borderRadius: BorderRadius.circular(8),
                    child: Center(
                      child: Text(
                        provider.currentYear.toString(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Кнопка "Плюс"
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: provider.currentYear < AppConstants.maxYear 
                      ? provider.nextYear 
                      : null,
                  tooltip: 'Следующий год',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Показывает диалог с сеткой выбора годов
  void _showYearGridDialog(BuildContext context, CalendarProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        // Вычисляем высоту экрана
        final screenHeight = MediaQuery.of(context).size.height;
        // Безопасная высота для bottom sheet (60% экрана, но не более 500px)
        final sheetHeight = screenHeight * 0.6;
        
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: sheetHeight,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Заголовок
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Выберите год',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                // Сетка годов (с прокруткой)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _buildYearGrid(context, provider),
                  ),
                ),
                // Кнопка закрытия (всегда видна)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Закрыть'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Строит сетку годов с автоматической прокруткой к выбранному году
  Widget _buildYearGrid(BuildContext context, CalendarProvider provider) {
    const int columns = 4; // Количество столбцов
    const int totalYears = AppConstants.maxYear - AppConstants.minYear + 1;
    
    // Создаем ScrollController
    final ScrollController scrollController = ScrollController();
    
    // Вычисляем индекс выбранного года
    final selectedIndex = provider.currentYear - AppConstants.minYear;
    
    // После построения виджета прокручиваем к выбранному году
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        // Вычисляем позицию для прокрутки
        // Каждый элемент имеет высоту примерно 60px (включая отступы)
        const itemHeight = 60.0;
        const itemsPerRow = columns;
        final rowIndex = selectedIndex ~/ itemsPerRow;
        final targetPosition = rowIndex * itemHeight;
        
        // Прокручиваем с анимацией
        scrollController.animateTo(
          targetPosition.clamp(0.0, scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    return GridView.builder(
      controller: scrollController,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.5,
      ),
      itemCount: totalYears,
      itemBuilder: (context, index) {
        final year = AppConstants.minYear + index;
        final isSelected = year == provider.currentYear;
        
        return Container(
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                provider.setYear(year);
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(8),
              child: Center(
                child: Text(
                  year.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected 
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}