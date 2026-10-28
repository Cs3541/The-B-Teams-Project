import 'package:flutter/material.dart';
import '../presenters/analytics_presenter.dart';
import '../presenters/sleep_data_presenter.dart';
import '../models/sleep_data_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


class AnalyticsListScreen extends StatefulWidget {
  const AnalyticsListScreen({super.key});

  @override
  State<AnalyticsListScreen> createState() => _AnalyticsListScreenState();
}

class _AnalyticsListScreenState extends State<AnalyticsListScreen> {
  final AnalyticsPresenter _presenter = AnalyticsPresenter(); 
  //Currently in test mode. Swap ".addTestEntries()" back to ".entries" after testing is done.
  final List<SleepData> sleeperData = SleepDataPresenter().addTestEntries();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Tab'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,        
          children: [
            Text(
              'Average Amount of Sleep: ${_presenter.getAverageSleep(sleeperData)} hours',
              style: TextStyle(
                fontSize: 24, 
                color: Colors.black,
                fontWeight: FontWeight.bold
              ),
            ),
            SfCartesianChart(
              series: <CartesianSeries<SleepData, int>>[
                  ColumnSeries<SleepData, int>(
                      dataSource: sleeperData,
                    
                    xValueMapper: (SleepData data, int index) => index,
                    yValueMapper: (SleepData data, _) => data.hours,
                  )
              ]
            )
           ],
        ),
      )
    );
  }
}