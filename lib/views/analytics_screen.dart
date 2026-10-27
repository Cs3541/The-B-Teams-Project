import 'package:flutter/material.dart';
import '../presenters/analytics_presenter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


class AnalyticsListScreen extends StatefulWidget {
  const AnalyticsListScreen({super.key});

  @override
  State<AnalyticsListScreen> createState() => _AnalyticsListScreenState();
}

class _AnalyticsListScreenState extends State<AnalyticsListScreen> {
  final AnalyticsPresenter _presenter = AnalyticsPresenter();


  @override
  Widget build(BuildContext context) {
    _presenter.addAnalyticsTest();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Tab'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,        
          children: [
            Text(
              'Average Amount of Sleep: ${_presenter.getAverageSleep(_presenter.analytics)} hours',
              style: TextStyle(
                fontSize: 24, 
                color: Colors.black,
                fontWeight: FontWeight.bold
              ),
            ), 

           ],
        ),
      ),
    );
      
    
  }
}