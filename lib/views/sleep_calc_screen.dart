import 'package:flutter/material.dart';
import 'app_top_bar.dart';
import '../presenters/sleep_calc_presenter.dart';


class SleepCalcScreen extends StatefulWidget {
  const SleepCalcScreen({super.key});

  @override
  State<SleepCalcScreen> createState() => _SleepCalcScreenState();
}

class _SleepCalcScreenState extends State<SleepCalcScreen> {
  final SleepCalcPresenter _presenter = SleepCalcPresenter();

  int _age = -1;
  bool _yearOrMonth = true;
  bool _sleepOrWakeUp = true;
  double _wakeOrSleepTime = 0.0;
  bool _isAMorPM = false;

    String _stringBasedOnSleepOrWakeUp() {
    String infoText = '';
    if (_sleepOrWakeUp == true) {
      setState(() {
        infoText = "Enter bedtime";
      });
    } else {
      setState(() {
        infoText = "Enter wake up time";
      });
    }
    return infoText;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Sleep Calculator'),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sleep Calculator',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                width: 180,
                  child:
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter age',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: TextStyle(fontSize: 16),
                    onChanged: (value) {
                      setState(() {
                        _age = int.tryParse(value) ?? -1;
                      });
                    },
                  ),
                ),
                SizedBox(
                width: 113, // Set your desired width here
                child: DropdownButtonFormField<bool>(
                    initialValue: _yearOrMonth==false,
                    items: const [
                      DropdownMenuItem(
                        value: true,
                        child: Text('Months Old'),
                      ),

                      DropdownMenuItem(
                        value: false,
                        child: Text('Years Old'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _yearOrMonth = value ?? false;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 160, // Set your desired width here
                child: DropdownButtonFormField<bool>(
                  initialValue: _sleepOrWakeUp==false,
                  items: const [
                    DropdownMenuItem(
                      value: true,
                      child: Text('Time to go to bed'),
                    ),

                    DropdownMenuItem(
                      value: false,
                      child: Text('Time to wake up'),
                    ),
                  ],
                onChanged: (value) {
                  setState(() {
                    _sleepOrWakeUp = value ?? false;
                  });
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                width: 180,
                  child:
                  TextField(
                    decoration: InputDecoration(
                      hintText: _stringBasedOnSleepOrWakeUp(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: TextStyle(fontSize: 16),
                    onChanged: (value) {
                      setState(() {
                        _wakeOrSleepTime = double.tryParse(value) ?? 0.0;
                      });
                    },

                  ),
                ),
                SizedBox(
                width: 113, // Set your desired width here
                child: DropdownButtonFormField<bool>(
                    initialValue: _isAMorPM==false,
                    items: const [
                      DropdownMenuItem(
                        value: true,
                        child: Text('AM'),
                      ),

                      DropdownMenuItem(
                        value: false,
                        child: Text('PM'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _isAMorPM = value ?? false;
                      });
                    },
                  ),
                ),
              ],
            ),

            
            

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _presenter.calculateSleepDuration(_age, _yearOrMonth, _sleepOrWakeUp, _wakeOrSleepTime, _isAMorPM);
              },
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate Sleep'),
            ),
          ],
        ),
      ),
    );
  }
}