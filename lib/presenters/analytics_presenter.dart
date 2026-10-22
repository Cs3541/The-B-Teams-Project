import '../models/analytics_model.dart';

class AnalyticsPresenter {
  final List<Analytics> _analytics = [];

  List<Analytics> get analytics => _analytics;

  void addAnalytics(String title) {
    if (title.trim().isNotEmpty) {
      _analytics.add(Analytics(title: title));
    }
  }

  void toggleCompleted(int index) {
      _analytics[index].isCompleted = !_analytics[index].isCompleted;
  }
}