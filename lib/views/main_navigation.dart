import 'package:flutter/material.dart';

import '../home_screen.dart';
import 'analytics_screen.dart';
import 'audio_screen.dart';
import 'articles_screen.dart';
import 'sleep_data_screen.dart';
import 'sleep_journal_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _tabIndex = ValueNotifier<int>(0);

  @override
  void dispose() {
    _tabIndex.dispose();
    super.dispose();
  }

  final List<Widget> _screens = <Widget>[
    const HomeScreen(),
    const AnalyticsListScreen(),
    const AudioListScreen(),
    const SleepDataScreen(),
    const SleepJournalScreen(),
    const ArticlesScreen(),
  ];

  void _onItemTapped(int index) {
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    setState(() {
      _selectedIndex = index;
      _tabIndex.value = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NavigatorPopHandler<void>(
        onPopWithResult: (_) => _navigatorKey.currentState!.pop(),
        child: Navigator(
          key: _navigatorKey,
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (_) => ValueListenableBuilder<int>(
              valueListenable: _tabIndex,
              builder: (_, index, _) =>
                  IndexedStack(index: index, children: _screens),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Sleep Audio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bedtime_outlined),
            label: 'Sleep Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Sleep Journal',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Articles'),
        ],
      ),
    );
  }
}
