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
  double _hours = 0;
  double _minutes = 0;
  bool _isAM = true;

  String resultTextString() {
    String infoText = '';
    double calculatedTime = _presenter.calculateSleepDuration(_age, _yearOrMonth, _sleepOrWakeUp, _hours, _minutes, _isAM);
    // The AM section
    if (_isAM){
      // Wake up time calculation
      if (!_sleepOrWakeUp){
      infoText = 'Calculated Wake Up Time1: ';
      }
      // bedtime calculation
      else if (_sleepOrWakeUp){
        infoText = 'Calculated Bedtime2: ';
      }
    }
    // The PM section
    if (!_isAM){
      // Wake up time calculation
      if (!_sleepOrWakeUp){
        infoText = 'Calculated Wake Up Time3: ';
      }
      // bedtime calculation
      else if (_sleepOrWakeUp){
        infoText = 'Calculated Bedtime4: ';
      }
    }

    if (calculatedTime >= 12) {
      infoText += '${calculatedTime - 12} PM';
    } else {
      infoText += '$calculatedTime AM';
    }

    return infoText;
  }

  Future<void> _showCalcDialog() async {
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sleep Calculation Result'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  resultTextString(),
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
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
                    initialValue: _yearOrMonth==true,
                    items: const [
                      DropdownMenuItem(
                        value: true,
                        child: Text('Years Old'),
                      ),

                      DropdownMenuItem(
                        value: false,
                        child: Text('Months Old'),
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
              width: 200, // Set your desired width here
                child: DropdownButtonFormField<bool>(
                  initialValue: _sleepOrWakeUp==true,
                  items: const [
                    DropdownMenuItem(
                      value: true,
                      child: Text('Enter Time to wake up'),
                    ),

                    DropdownMenuItem(
                      value: false,
                      child: Text('Enter Time to go to bed'),
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
                width: 60,
                  child:
                  TextField(
                    decoration: InputDecoration(
                      hintText: '00',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: TextStyle(fontSize: 16),
                    onChanged: (value) {
                      setState(() {
                        _hours = double.tryParse(value) ?? 0.0;
                      });
                    },

                  ),
                ),
                Text(
                  ':',
                  style: TextStyle(fontSize: 30),
                ),
                SizedBox(
                width: 60,
                  child:
                  TextField(
                    decoration: InputDecoration(
                      hintText: '00',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: TextStyle(fontSize: 16),
                    onChanged: (value) {
                      setState(() {
                        _minutes = double.tryParse(value) ?? 0.0;
                      });
                    },

                  ),
                ),
                SizedBox(
                width: 90, // Set your desired width here
                child: DropdownButtonFormField<bool>(
                    initialValue: _isAM==true,
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
                        _isAM = value ?? false;
                      });
                    },
                  ),
                ),
              ],
            ),

            
            

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _showCalcDialog();
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