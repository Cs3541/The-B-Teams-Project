import '../models/sleep_data_model.dart';

class AnalyticsPresenter {

  double getAverageSleep(List<SleepData> data) {
    double totalSleep = 0;
  
    for (int i = 0; i < data.length; i++){
      SleepData temp = data.elementAt(i);
      totalSleep += temp.hours;
    }
    double avgSleep = totalSleep/data.length;
    return double.parse((avgSleep).toStringAsFixed(2));
}
}
