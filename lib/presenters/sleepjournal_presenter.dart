import '../models/sleepjournal_model.dart';

class SleepJournalPresenter {
  final List<SleepJournal> _journals = [];

  List<SleepJournal> get journals {
    final sortedJournals = List<SleepJournal>.from(_journals);
    sortedJournals.sort(
      (a, b) => b.journalDate.compareTo(a.journalDate),
    );
    return sortedJournals;
  }

  void addJournal({
    required String title,
    required String content,
  }) {
    final journal = SleepJournal(
      title: title,
      content: content,
      journalDate: DateTime.now(),
    );
    _journals.add(journal);
  }

  List<SleepJournal> searchJournals(String query){
    if(query.toString().isEmpty){
      return journals;
    }
    final matchingJournals = _journals.where((journal) {
      return journal.title.toLowerCase().contains(query.toLowerCase()) ||
      journal.content.toLowerCase().contains(query.toLowerCase());
    }).toList();

    matchingJournals.sort(
      (a, b) => b.journalDate.compareTo(a.journalDate)
    );
    return matchingJournals;
  }

  void deleteJournals(SleepJournal journal){
    _journals.remove(journal);
  }
}