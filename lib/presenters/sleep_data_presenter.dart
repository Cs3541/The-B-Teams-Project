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
}
