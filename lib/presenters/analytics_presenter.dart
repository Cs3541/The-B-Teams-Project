import '../models/analytics_model.dart';

class AnalyticsPresenter {
  final List<Analytics> _analytics = [];

  List<Analytics> get analytics => _analytics;

  void addAnalytics(List<String> sleep) {
    if (sleep.isNotEmpty) {
      _analytics.add(Analytics(sleep: sleep));
    }
  }
}