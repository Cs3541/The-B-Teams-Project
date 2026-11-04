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
  final SleepLogPresenter _sleepLogPresenter = SleepLogPresenter();
  List<SleepLog> _logs = [];
    bool _isLoading = true;

  Future<void> _loadLogs() async {
    try {
      final logs = await _sleepLogPresenter.loadLogs();

      if (!mounted) return;

      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      _showMessage(error.toString());
    }
  }
    void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    _loadLogs();
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? const Center(
                  child: Text(
                    'No sleep logs available.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              
      :Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Average Amount of Sleep: ${_presenter.getAverageSleep(_logs)} hours',
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SfCartesianChart(
              series: <CartesianSeries<SleepLog, int>>[
                ColumnSeries<SleepLog, int>(
                  dataSource: _logs,

                  xValueMapper: (SleepLog data, int index) => index,
                  yValueMapper: (SleepLog data, _) => data.duration.inMinutes / 60, // Convert to hours

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
