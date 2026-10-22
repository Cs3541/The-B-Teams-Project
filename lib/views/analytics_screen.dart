import 'package:flutter/material.dart';
import '../presenters/analytics_presenter.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  final AnalyticsPresenter _presenter = AnalyticsPresenter();

  void _showAddAssignmentDialog() {
    String newAssignmentTitle = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Assignment'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter assignment title'),
            onChanged: (value) {
                  newAssignmentTitle = value;
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), //Cancel button
                    child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (newAssignmentTitle.trim().isNotEmpty) {
                      setState(() {
                        _presenter.addAnalytics(newAssignmentTitle.trim());
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
          return CheckboxListTile(
            title: Text(analytic.title),
            value: analytic.isCompleted,
              onChanged: (value) {
                setState(() {
                  _presenter.toggleCompleted(index);
                });
              },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAssignmentDialog,
        child: const Icon(Icons.add),
      ),
    );
      
    
  }
}