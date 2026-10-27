import 'package:flutter/material.dart';

import '../presenters/sleep_data_presenter.dart';

class SleepDataScreen extends StatefulWidget {
  const SleepDataScreen({super.key});

  @override
  State<SleepDataScreen> createState() => _SleepDataScreenState();
}

class _SleepDataScreenState extends State<SleepDataScreen> {
  final SleepDataPresenter _presenter = SleepDataPresenter();

  Future<void> _showAddDialog() async {
    String hours = '';
    String? error;
    DateTime date = DateUtils.dateOnly(DateTime.now());
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, updateDialog) => AlertDialog(
          title: const Text('Add Sleep Data'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    MaterialLocalizations.of(context).formatMediumDate(date),
                  ),
                  onPressed: () async {
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (selected != null && context.mounted) {
                      updateDialog(() => date = selected);
                    }
                  },
                ),
                TextField(
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Hours slept',
                    hintText: 'e.g. 7.5',
                    errorText: error,
                  ),
                  onChanged: (value) => hours = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (!_presenter.addEntry(date, hours)) {
                  updateDialog(
                    () => error = 'Enter hours greater than 0 and up to 24',
                  );
                  return;
                }
                setState(() {});
                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _presenter.entries;
    return Scaffold(
      appBar: AppBar(title: const Text('Sleep Data')),
      body: entries.isEmpty
          ? const Center(child: Text('No sleep records yet. Tap + to add one.'))
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return ListTile(
                  leading: const Icon(Icons.bedtime_outlined),
                  title: Text('${entry.hours} hours'),
                  subtitle: Text(
                    MaterialLocalizations.of(context)
                        .formatMediumDate(entry.date),
                  ),
                  trailing: IconButton(
                    tooltip: 'Delete sleep record',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () =>
                        setState(() => _presenter.removeEntry(entry)),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addSleepRecord',
        tooltip: 'Add sleep record',
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
