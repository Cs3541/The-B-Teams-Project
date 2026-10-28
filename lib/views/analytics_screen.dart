
import 'package:flutter/material.dart';
import '../presenters/analytics_presenter.dart';

class AnalyticsListScreen extends StatefulWidget {
  const AnalyticsListScreen({super.key});

  @override
  State<AnalyticsListScreen> createState() =>
      _AnalyticsListScreenState();
}

class _AnalyticsListScreenState extends State<AnalyticsListScreen> {
  final AnalyticsPresenter _presenter = AnalyticsPresenter();

  @override
  void initState() {
    super.initState();
    // Only add test data here if you actually need it.
    // _presenter.addAnalyticsTest();
  }

  Future<void> _showAddAnalyticsDialog() async {
    final formKey = GlobalKey<FormState>();
    String sleepData = '';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Sleep Data'),
        content: Form(
          key: formKey,
          child: TextFormField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Sleep data',
              hintText: 'e.g. Slept 8 hours, woke up rested',
            ),
            onChanged: (value) => sleepData = value,
            validator: (value) =>
                value == null || value.trim().isEmpty
                    ? 'Enter sleep data'
                    : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;

              setState(() {
                _presenter.addAnalytics([sleepData.trim()]);
              });

              Navigator.pop(dialogContext);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analytics = _presenter.analytics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Tab'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Average Amount of Sleep: '
              '${_presenter.getAverageSleep(analytics)} hours',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (analytics.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No sleep data yet. Tap + to add an entry.'),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: analytics.length,
                itemBuilder: (context, index) {
                  final analytic = analytics[index];

                  return ListTile(
                    leading: const Icon(Icons.bedtime_outlined),
                    title: Text(analytic.sleep.join(', ')),
                    trailing: IconButton(
                      tooltip: 'Delete sleep data',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        setState(() {
                          _presenter.removeAnalytics(analytic);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addSleepData',
        tooltip: 'Add sleep data',
        onPressed: _showAddAnalyticsDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
