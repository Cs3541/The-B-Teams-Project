import 'package:flutter/material.dart';
import 'app_top_bar.dart';
import '../presenters/analytics_presenter.dart';
import '../models/sleep_log_model.dart';
import '../presenters/sleep_log_presenter.dart';


import 'package:syncfusion_flutter_charts/charts.dart';

class AnalyticsListScreen extends StatefulWidget {
  const AnalyticsListScreen({super.key});

  @override
  State<AnalyticsListScreen> createState() => _AnalyticsListScreenState();
}

class _AnalyticsListScreenState extends State<AnalyticsListScreen> {
  final AnalyticsPresenter _presenter = AnalyticsPresenter();
  final List<SleepLog> sleepLogs = SleepLogPresenter().getSleepLogs();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(
        title: 'Analytics Tab',
        titleStyle: TextStyle(
          fontSize: 24,
          color: Colors.white60,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Average Amount of Sleep: ${_presenter.getAverageSleep(sleepLogs)} hours',
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SfCartesianChart(
              series: <CartesianSeries<SleepLog, int>>[
                ColumnSeries<SleepLog, int>(
                  dataSource: sleepLogs,

                  xValueMapper: (SleepLog data, int index) => index,
                  yValueMapper: (SleepLog data, _) => data.duration.inHours,

                  width: .98,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
