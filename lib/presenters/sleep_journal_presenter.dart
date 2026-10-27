import '../models/sleep_journal_model.dart';

class SleepJournalPresenter {
  final List<SleepJournalEntry> _entries = [];

  List<SleepJournalEntry> get entries => List.unmodifiable(_entries);

  bool addEntry(DateTime date, String note) {
    if (note.trim().isEmpty) return false;
    _entries.insert(0, SleepJournalEntry(date: date, note: note.trim()));
    return true;
  }

  void removeEntry(SleepJournalEntry entry) => _entries.remove(entry);
}
