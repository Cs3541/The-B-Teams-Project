import 'package:flutter/material.dart';
import '../presenters/analytics_presenter.dart';

class AnalyticsListScreen extends StatefulWidget {
  const AnalyticsListScreen({super.key});

  @override
  State<AnalyticsListScreen> createState() => _AnalyticsListScreenState();
}

class _AnalyticsListScreenState extends State<AnalyticsListScreen> {
  final AnalyticsPresenter _presenter = AnalyticsPresenter();

  void _showAddAnalyticsDialog() {
    List<String> newSleepData = [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Sleep Data'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter sleep data'),
            onChanged: (value) {
                  newSleepData.add(value);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), //Cancel button
                    child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (newSleepData.isNotEmpty) {
                      setState(() {
                        _presenter.addAnalytics(newSleepData);
                      });
                    }
                    Navigator.pop(context); //Close dialong
                  },
                  child: const Text('Add'),
                ),
              ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final analytics = _presenter.analytics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Tab'),
      ),
      body: ListView.builder(
        itemCount: analytics.length,
        itemBuilder: (context, index) {
          final analytic = analytics[index];
          return Text(analytic.sleep.join(', '));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAnalyticsDialog,
        child: const Icon(Icons.add),
      ),
    );
      
    
  }
}