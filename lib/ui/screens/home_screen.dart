// Главный экран приложения с анимацией волны при смене года.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/animation_constants.dart';
import '../../constants/app_constants.dart';
import '../../localization/app_strings.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/year_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _flipController;
  late final List<Animation<double>> _tileAnimations;

  @override
  void initState() {
    super.initState();
    
    _flipController = AnimationController(
      vsync: this,
      duration: AnimationConstants.totalAnimationDuration,
    );
    
    _tileAnimations = List.generate(
      AppConstants.monthsInYear,
      (index) {
        final start = index * AnimationConstants.staggerDelay;
        final end = (start + AnimationConstants.tileAnimationDuration).clamp(0.0, 1.0);
        return CurvedAnimation(
          parent: _flipController,
          curve: Interval(
            start.clamp(0.0, 1.0),
            end,
            curve: Curves.easeInOut,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeaderRow(context),
            Expanded(
              child: Consumer<CalendarProvider>(
                builder: (context, calendarProvider, child) {
                  return CalendarGrid(
                    year: calendarProvider.currentYear,
                    flipController: _flipController,
                    tileAnimations: _tileAnimations,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _AppTitleWithTripleTap(
              title: AppStrings.appTitle,
              textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                  icon: Icon(themeProvider.themeIcon),
                  tooltip: AppStrings.changeThemeTooltip,
                  onPressed: themeProvider.toggleTheme,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(36, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              );
            },
          ),
          const YearSelector(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: const Icon(Icons.today, size: 20),
              tooltip: 'Текущий год',
              onPressed: () {
                context.read<CalendarProvider>().setYear(DateTime.now().year);
              },
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                padding: EdgeInsets.zero,
                minimumSize: const Size(36, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppTitleWithTripleTap extends StatefulWidget {
  final String title;
  final TextStyle? textStyle;

  const _AppTitleWithTripleTap({
    required this.title,
    this.textStyle,
  });

  @override
  State<_AppTitleWithTripleTap> createState() => _AppTitleWithTripleTapState();
}

class _AppTitleWithTripleTapState extends State<_AppTitleWithTripleTap> {
  int _tapCount = 0;
  DateTime? _lastTapTime;

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTapTime == null || now.difference(_lastTapTime!).inMilliseconds > 500) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }
    _lastTapTime = now;

    if (_tapCount == 3) {
      _tapCount = 0;
      _showDeveloperInfo();
    }
  }

  void _showDeveloperInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('О разработчике'),
          content: const Text(
            '🗓️Марков К.Б.\nEmail: kbmarkov@gmail.com\n©2026',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Text(
          widget.title,
          style: widget.textStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}