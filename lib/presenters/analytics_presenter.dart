import '../models/analytics_model.dart';

class AnalyticsPresenter {
  final List<Analytics> _analytics = [];

  List<Analytics> get analytics => List.unmodifiable(_analytics);


  void addAnalyticsTest() {
      _analytics.add(Analytics(hours: 8));
      _analytics.add(Analytics(hours: 8));
      _analytics.add(Analytics(hours: 8));
      _analytics.add(Analytics(hours: 8));
      _analytics.add(Analytics(hours: 8));
      _analytics.add(Analytics(hours: 8));
      _analytics.add(Analytics(hours: 8));
  }


  void addAnalytics(Analytics sleep) {
      _analytics.add(sleep);
  }
  

  double getAverageSleep(List<Analytics> a) {
    double totalSleep = 0;
  
    for (int i = 0; i < a.length; i++){
      totalSleep += a[i].hours;
    }
    double avgSleep = totalSleep/a.length;
    return double.parse((avgSleep).toStringAsFixed(2));
}

}
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
