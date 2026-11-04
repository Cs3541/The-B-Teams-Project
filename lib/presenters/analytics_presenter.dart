import '../models/sleep_log_model.dart';

class AnalyticsPresenter {

  double getAverageSleep(List<SleepLog> data) {
    double totalSleep = 0;
  
    for (int i = 0; i < data.length; i++){
      SleepLog temp = data.elementAt(i);
      totalSleep += temp.duration.inMinutes / 60; // Convert duration to hours
    }
    double avgSleep = totalSleep/data.length;
    return double.parse((avgSleep).toStringAsFixed(2));
}
}
