import '../models/analytics_model.dart';

class AnalyticsPresenter {
  final List<Analytics> _analytics = [];

  List<Analytics> get analytics => List.unmodifiable(_analytics);

  void addAnalytics(List<String> sleep) {
    final entries = sleep
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    if (entries.isNotEmpty) {
      _analytics.add(Analytics(sleep: List.unmodifiable(entries)));
    }
  }

  void removeAnalytics(Analytics analytics) => _analytics.remove(analytics);
}
