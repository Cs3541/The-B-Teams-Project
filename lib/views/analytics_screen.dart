import 'package:flutter/material.dart';

import '../presenters/analytics_presenter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


class AnalyticsListScreen extends StatefulWidget {
  const AnalyticsListScreen({super.key});

  @override
  State<AnalyticsListScreen> createState() => _AnalyticsListScreenState();
}

class _AnalyticsListScreenState extends State<AnalyticsListScreen> {
  final AnalyticsPresenter _presenter = AnalyticsPresenter();


  @override
  Widget build(BuildContext context) {
    _presenter.addAnalyticsTest();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Tab'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,        
          children: [
            Text(
              'Average Amount of Sleep: ${_presenter.getAverageSleep(_presenter.analytics)} hours',
              style: TextStyle(
                fontSize: 24, 
                color: Colors.black,
                fontWeight: FontWeight.bold
              ),
              )
              Text('No sleep data yet. Tap + to add an entry.'),
              
              ListView.builder(
              itemCount: analytics.length,
              itemBuilder: (context, index) {
                final analytic = analytics[index];
                return ListTile(
                  leading: const Icon(Icons.bedtime_outlined),
                  title: Text(analytic.sleep.join(', ')),
                  trailing: IconButton(
                    tooltip: 'Delete sleep data',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () =>
                        setState(() => _presenter.removeAnalytics(analytic)),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addSleepData',
        tooltip: 'Add sleep data',
        onPressed: _showAddAnalyticsDialog,
        child: const Icon(Icons.add),
            ), 

           ],
        ),
      ),
    );
  }
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
            validator: (value) => value == null || value.trim().isEmpty
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
              setState(() => _presenter.addAnalytics([sleepData]));
              Navigator.pop(dialogContext);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
