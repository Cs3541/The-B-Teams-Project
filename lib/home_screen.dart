import 'package:flutter/material.dart';

import 'views/app_top_bar.dart';

import 'views/sleep_log_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Home'),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'The Sweet Dreams App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SleepLogScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.bedtime),
              label: const Text('Log My Sleep'),
            ),
          ],
        ),
      ),
    );
  }
}
