
import 'package:flutter/material.dart';
import 'views/app_top_bar.dart';
import 'views/sleep_log_screen.dart';
import 'views/sleep_calc_screen.dart';
import 'views/checklist_screen.dart';

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
            const Text(
              'The Sweet Dreams App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // Log My Sleep Button
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

            const SizedBox(height: 16),

            // Featured Articles Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ChecklistScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.checklist),
              label: const Text('Daily Check List'),
            ),

            const SizedBox(height: 16),

            // Calculate Sleep Schedule Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SleepCalcScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate A Sleep Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}
