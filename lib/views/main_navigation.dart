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

  final List<Widget> _screens = <Widget>[
    const HomeScreen(),
    const AnalyticsListScreen(),
    const AudioListScreen(),
    const ArticlesScreen(),
    const SleepDataScreen(),
    const SleepJournalScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Articles',
          ),
        ],
      ),
    );
  }
}
