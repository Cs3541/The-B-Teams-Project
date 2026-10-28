
import '../models/analytics_model.dart';

class AnalyticsPresenter {
  final List<Analytics> _analytics = [];

  List<Analytics> get analytics => List.unmodifiable(_analytics);

  double getAverageSleep(List<Analytics> analytics) {
    if (analytics.isEmpty) return 0.0;

    // This assumes each Analytics object contains numeric sleep hours
    // represented as strings, such as ["8"] or ["7.5"].
    double totalSleep = 0;
    int count = 0;

    for (final analytic in analytics) {
      for (final value in analytic.sleep) {
        final hours = double.tryParse(value);

        if (hours != null) {
          totalSleep += hours;
          count++;
        }
      }
    }

    if (count == 0) return 0.0;

    return double.parse((totalSleep / count).toStringAsFixed(2));
  }

  void addAnalytics(List<String> sleep) {
    final entries = sleep
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();

    if (entries.isNotEmpty) {
      _analytics.add(
        Analytics(sleep: List.unmodifiable(entries)),
      );
    }
  }

  void removeAnalytics(Analytics analytics) {
    _analytics.remove(analytics);
  }
}
