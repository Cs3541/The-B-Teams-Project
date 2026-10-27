import '../models/analytics_model.dart';
import '../models/sleep_data_model.dart';

class AnalyticsPresenter {
  final List<Analytics> _analytics = [];

  List<Analytics> get analytics => List.unmodifiable(_analytics);


  double getAverageSleep(List<SleepData> data) {
    double totalSleep = 0;
  
    for (int i = 0; i < _analytics.length; i++){
      totalSleep += data.elementAt(i);
    }
    double avgSleep = totalSleep/_analytics.length;
    return double.parse((avgSleep).toStringAsFixed(2));
}
}
