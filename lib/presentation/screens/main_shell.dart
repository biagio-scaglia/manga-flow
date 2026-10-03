import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manga_library/core/theme/app_colors.dart';
import 'package:manga_library/presentation/controllers/settings_controller.dart';
import 'package:manga_library/presentation/screens/home/home_screen.dart';
import 'package:manga_library/presentation/screens/library/library_screen.dart';
import 'package:manga_library/presentation/screens/search/search_screen.dart';
import 'package:manga_library/presentation/screens/statistics/statistics_screen.dart';
import 'package:manga_library/presentation/tutorial/tutorial_overlay.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _checkedTutorial = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_checkedTutorial) {
      _checkedTutorial = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndShowTutorial();
      });
    }
  }

  void _checkAndShowTutorial() {
    final settingsCtrl = context.read<SettingsController>();
    if (!settingsCtrl.tutorialCompleted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => TutorialDialog(
          onComplete: () {
            Navigator.of(context).pop();
          },
        ),
      );
    }
  }

  void _setTabIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            onNavigateToSearch: () => _setTabIndex(2),
            onNavigateToLibrary: () => _setTabIndex(1),
          ),
          LibraryScreen(
            onNavigateToSearch: () => _setTabIndex(2),
          ),
          const SearchScreen(),
          StatisticsScreen(
            onNavigateToSearch: () => _setTabIndex(2),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.nightBorder : AppColors.paperBorder,
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _setTabIndex,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: '01 HOME',
            ),
            NavigationDestination(
              icon: Icon(Icons.collections_bookmark_outlined),
              selectedIcon: Icon(Icons.collections_bookmark_rounded),
              label: '02 LIBRERIA',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search_rounded),
              label: '03 CERCA',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights_rounded),
              label: '04 STATS',
            ),
          ],
        ),
      ),
    );
  }
}
