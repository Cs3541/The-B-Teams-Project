import 'package:flutter/material.dart';

import '../models/settings_model.dart';
import 'app_top_bar.dart';
import 'settings_scope.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final presenter = SettingsScope.of(context);
    return Scaffold(
      appBar: const AppTopBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Background color',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Choose a background for the app.'),
          const SizedBox(height: 16),
          for (final option in BackgroundColor.values)
            ListTile(
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: option.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black26),
                ),
              ),
              title: Text(option.label),
              selected: presenter.background == option,
              trailing: presenter.background == option
                  ? const Icon(Icons.check)
                  : null,
              onTap: () async {
                try {
                  await presenter.setBackground(option);
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Color applied, but could not save it for next time.',
                      ),
                    ),
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}
