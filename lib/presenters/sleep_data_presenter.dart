import '../models/sleep_data_model.dart';

class SleepDataPresenter {
  final List<SleepData> _entries = [];

  List<SleepData> get entries => List.unmodifiable(_entries);

  bool addEntry(DateTime date, String hoursText) {
    final hours = double.tryParse(hoursText.trim());
    if (hours == null || !hours.isFinite || hours <= 0 || hours > 24) {
      return false;
    }
    _entries.insert(0, SleepData(date: date, hours: hours));
    return true;
  }

  void removeEntry(SleepData entry) => _entries.remove(entry);

    //A test class designed to test the analytics section.
    List<SleepData> addTestEntries() {
    _entries.insert(0, SleepData(date: DateTime.utc(1989, 11, 9), hours: 1));
    _entries.insert(0, SleepData(date: DateTime.utc(1989, 11, 10), hours: 9));
    _entries.insert(0, SleepData(date: DateTime.utc(1989, 11, 11), hours: 5));
    return _entries;
  }

}
