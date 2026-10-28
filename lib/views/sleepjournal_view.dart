import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../presenters/sleepjournal_presenter.dart';
import '../models/sleepjournal_model.dart';

class SleepJournalView extends StatefulWidget {
  const SleepJournalView({super.key});

  @override
  State<SleepJournalView> createState() => _SleepJournalViewState();
}

class _SleepJournalViewState extends State<SleepJournalView> {
  final SleepJournalPresenter _sleepJournalPresenter = SleepJournalPresenter();

  String _searchQuery = '';

  Future<void> _showAddJournalDialog() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('New sleep journal'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title of entry',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentController,
                    maxLines: 6,
                    minLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Journal entry',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if(titleController.text.trim().isEmpty ||
                contentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter the title and contents of this journal',
                      ),
                    ),
                  );
                  return;
                }
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Save entry'),
            ),
          ],
        );
      },
    );

    if(shouldSave == true && mounted){
      _sleepJournalPresenter.addJournal(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
      );
      setState(() {});
    }
  }
  void _deleteJournal(SleepJournal journal){
    setState(() {
      _sleepJournalPresenter.deleteJournals(journal);
    });
  }

  Widget _buildJournalCard(SleepJournal journal){
    final formattedDate = DateFormat(
      'MMMM dd, yyyy | h:mm a',
    ).format(journal.journalDate);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          journal.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedDate,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(journal.content),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Delete Entry',
          onPressed: () => _deleteJournal(journal),
        ),
      ),
    );
  }

  @override
  Widget build( BuildContext context){
    final journals = _sleepJournalPresenter.searchJournals(
      _searchQuery,
    );

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
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value){
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: journals.isEmpty
            ? Center(
              child: Text(_searchQuery.isEmpty
              ? 'No existing journal entries'
              : 'No journal entries matching your search',
              textAlign: TextAlign.center,
              ),
            )
            : ListView.builder(
              itemCount: journals.length,
              itemBuilder: (context, index) {
                return _buildJournalCard(journals[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddJournalDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}


/*
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
*/