import 'package:flutter/material.dart';
import '../presenters/sleepjournal_presenter.dart';

class SleepJournalView extends StatefulWidget {
  const SleepJournalView({super.key});
  
  @override
  _SleepJournalViewState createState() => _SleepJournalViewState();
}

class _SleepJournalViewState extends State<SleepJournalView> {
  final SleepJournalPresenter _sleepJournalPresenter = SleepJournalPresenter();

  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Journal'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search sleep journal entries...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ), //Textfield
          ), //Padding
        ]
      ),
    );
  }
}