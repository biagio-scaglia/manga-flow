import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';
import '../tutorial/tutorial_overlay.dart';
import 'home/home_screen.dart';
import 'library/library_screen.dart';
import 'search/search_screen.dart';
import 'statistics/statistics_screen.dart';

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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _setTabIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.collections_bookmark_outlined),
            selectedIcon: Icon(Icons.collections_bookmark_rounded),
            label: 'Libreria',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Cerca',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Statistiche',
          ),
        ],
      ),
    );
  }
}
