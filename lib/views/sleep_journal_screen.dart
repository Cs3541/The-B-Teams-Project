import 'package:flutter/material.dart';

import '../presenters/sleep_journal_presenter.dart';

class SleepJournalScreen extends StatefulWidget {
  const SleepJournalScreen({super.key});

  @override
  State<SleepJournalScreen> createState() => _SleepJournalScreenState();
}

class _SleepJournalScreenState extends State<SleepJournalScreen> {
  final SleepJournalPresenter _presenter = SleepJournalPresenter();

  Future<void> _showAddDialog() async {
    final formKey = GlobalKey<FormState>();
    String note = '';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Journal Entry'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: TextFormField(
              autofocus: true,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Sleep notes',
                hintText: 'How did you sleep? Any dreams or thoughts?',
              ),
              onChanged: (value) => note = value,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a journal note'
                  : null,
            ),
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
              setState(() => _presenter.addEntry(DateTime.now(), note));
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
    final entries = _presenter.entries;
    return Scaffold(
      appBar: AppBar(title: const Text('Sleep Journal')),
      body: entries.isEmpty
          ? const Center(
              child: Text('No journal entries yet. Tap + to write one.'),
            )
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: Text(
                    MaterialLocalizations.of(context)
                        .formatMediumDate(entry.date),
                  ),
                  subtitle: Text(entry.note),
                  trailing: IconButton(
                    tooltip: 'Delete journal entry',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () =>
                        setState(() => _presenter.removeEntry(entry)),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addJournalEntry',
        tooltip: 'Add journal entry',
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
