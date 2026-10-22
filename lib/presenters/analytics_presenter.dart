import '../models/analytics_model.dart';

class AnalyticsPresenter {
  final List<Analytics> _analytics = [];

  List<Analytics> get analytics => _analytics;


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